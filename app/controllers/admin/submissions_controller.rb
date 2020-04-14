class Admin::SubmissionsController < AdminController
  skip_before_action :verify_authenticity_token, only: [:send_email_reminder]
  include ActionView::Helpers::UrlHelper

  def redirect_to_default_dashboard
    redirect_to admin_submissions_dashboard_path(DegreeType.default)
  end

  def dashboard
    # Reset session semester to current semester when returning to dashboard
    session[:semester] = Semester.current
    degree_type = params[:degree_type] || DegreeType.default
    @view = Admin::SubmissionsDashboardView.new(degree_type)
  end

  def edit
    @submission = Submission.find(params[:id])
    @view = Admin::SubmissionFormView.new(@submission, session)
  end

  def update
    @submission = Submission.find(params[:id])
    if @submission.status_behavior.beyond_collecting_format_review_files? && @submission.status != 'format review completed'
      submission_update_service = FinalSubmissionUpdateService.new(params, @submission, current_remote_user)
    else
      submission_update_service = FormatReviewUpdateService.new(params, @submission, current_remote_user)
    end
    response = submission_update_service.update_record
    @submission.update_status_from_committee if @submission.status == 'waiting for committee review' || @submission.status == 'waiting for head of program review'
    flash[:notice] = response[:msg]
    redirect_to response[:redirect_path]
  rescue ActiveRecord::RecordInvalid
    @view = Admin::SubmissionFormView.new(@submission, session)
    render :edit
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Oops! You may have submitted invalid format review data. Please check that the submission\'s format review information is correct.'
  end

  def index
    session[:return_to] = request.referer
    @view = Admin::SubmissionsIndexView.new(params[:degree_type], params[:scope], view_context, session[:semester])
  end

  def audit
    @submission = Submission.find(params[:id])
    @author = @submission.author
    @most_relevant_file_links = most_relevant_file_links
  end

  def bulk_destroy
    # return_path = request.referer
    ids = params[:submission_ids].split(',')
    ids.each do |id|
      submission = Submission.find(id)
      submission.author_edit = false
      unless submission.nil?
        OutboundLionPathRecord.new(submission: submission).report_deleted_submission
        submission.destroy
      end
    end
    flash[:notice] = 'Submissions deleted successfully'
    redirect_to Rails.application.routes.url_helpers.admin_root_path
  rescue StandardError
    flash[:alert] = 'There was a problem deleting your submissions'
    redirect_to return_path
  end

  def release_for_publication
    ids = params[:submission_ids].split(',')
    results = Submission.release_for_publication(ids, Date.strptime(params[:date_to_release], '%m/%d/%Y'), params[:release_type])
    # error = results[1] *****MUST DISPLAY ERRORS
    flash[:notice] = results[0]
    render 'admin/submissions/publication_release_results', locals: { results: results[1] }
    # redirect_to admin_submissions_dashboard_path(params[:degree_type])
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'There was a problem releasing the submissions, please try again.'
    redirect_to session.delete(:return_to)
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Oops! You may have submitted invalid format review data. Please check that the submission\'s format review information is correct.'
  end

  def extend_publication_date
    session[:return_to] = request.referer
    ids = params[:submission_ids].split(',')
    new_date = Date.strptime(params[:date_to_release], '%m/%d/%Y')
    Submission.extend_publication_date(ids, new_date)
    flash[:notice] = "Submission publication dates have been extended until #{new_date}"
    redirect_to session.delete(:return_to) unless Rails.env.test?
  end

  def record_format_review_response
    @submission = Submission.find(params[:id])
    format_review_update_service = FormatReviewUpdateService.new(params, @submission, current_remote_user)
    response = format_review_update_service.respond_format_review
    redirect_to response[:redirect_path]
    flash[:notice] = response[:msg]
  rescue ActiveRecord::RecordInvalid
    @view = Admin::SubmissionFormView.new(@submission, session)
    render :edit
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to session.delete(:return_to)
    flash[:alert] = 'This submission\'s format review information has already been evaluated.'
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Oops! You may have submitted invalid format review data. Please check that the submission\'s format review information is correct.'
  end

  def update_final_submission
    @submission = Submission.find(params[:id])
    update_service = FinalSubmissionUpdateService.new(params, @submission, current_remote_user)
    response = update_service.waiting_for_final_submission
    redirect_to response[:redirect_path]
    flash[:notice] = response[:msg]
  rescue ActiveRecord::RecordInvalid
    @view = Admin::SubmissionFormView.new(@submission, session)
    render :edit
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to session.delete(:return_to)
    flash[:alert] = 'This submission\'s final submission information has already been evaluated.'
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Oops! You may have submitted invalid final submission data. Please check that the submission\'s final submission information is correct.'
  end

  def record_final_submission_response
    @submission = Submission.find(params[:id])
    update_service = FinalSubmissionUpdateService.new(params, @submission, current_remote_user)
    response = update_service.respond_final_submission
    redirect_to response[:redirect_path]
    flash[:notice] = response[:msg]
  rescue ActiveRecord::RecordInvalid
    @view = Admin::SubmissionFormView.new(@submission, session)
    render :edit
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to session.delete(:return_to)
    flash[:alert] = 'This submission\'s final submission information has already been evaluated.'
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Oops! You may have submitted invalid final submission data. Please check that the submission\'s final submission information is correct.'
  end

  def update_waiting_to_be_released
    @submission = Submission.find(params[:id])
    released_submission_service = FinalSubmissionUpdateService.new(params, @submission, current_remote_user)
    response = released_submission_service.respond_waiting_to_be_released
    flash[:notice] = response[:msg]
    redirect_to response[:redirect_path]
  rescue ActiveRecord::RecordInvalid
    @view = Admin::SubmissionFormView.new(@submission, session)
    render :edit
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Submission is invalid'
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Oops! You may have submitted invalid format review data. Please check that the submission\'s format review information is correct.'
  end

  def update_released
    @submission = Submission.find(params[:id])
    session[:return_to] = "/admin/#{@submission.degree_type.slug}"
    released_submission_service = FinalSubmissionUpdateService.new(params, @submission, current_remote_user)
    response = released_submission_service.respond_released_submission
    flash[:notice] = response[:msg]
    redirect_to response[:redirect_path]
  rescue ActiveRecord::RecordInvalid
    @view = Admin::SubmissionFormView.new(@submission, session)
    render :edit
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Submission is invalid'
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to session.delete(:return_to)
    flash[:alert] = 'Oops! You may have submitted invalid format review data. Please check that the submission\'s format review information is correct.'
  end

  def print_signatory_page
    return if params[:id].nil?

    @submission = Submission.find(params[:id])
    author = Author.find(@submission.author_id)
    @view = Admin::SignatoryPageView.new(author)
    return if author.nil?

    render 'admin/submissions/print/signatory_page', target: :blank, locals: { submission: @submission, author: author }
  end

  def print_signatory_page_update
    return if params[:id].nil?

    @submission = Submission.find(params[:id])
    @submission.update_attribute :is_printed, 1 unless @submission.is_printed?
    redirect_to admin_submissions_index_path(@submission.degree_type.slug, 'format_review_submitted')
    flash[:notice] = "Printed submission information for #{@submission.author.first_name} #{@submission.author.last_name}"
  end

  def refresh_committee
    @submission = Submission.find(params[:id])
    @submission.author.populate_lion_path_record(@submission.author.psu_idn, @submission.author.access_id)
    if @submission.academic_plan.committee_members_refresh
      flash[:notice] = 'Committee successfully refreshed from Lion Path'
    else
      flash[:alert] = 'Unable to refresh committee member information from Lion Path.'
    end
    redirect_to admin_edit_submission_path(@submission.id)
  end

  def refresh_academic_plan
    @submission = Submission.find(params[:id])
    if @submission.author.inbound_lion_path_record.refresh_academic_plan(@submission)
      flash[:notice] = 'Academic plan information successfully refreshed from Lion Path'
    else
      flash[:alert] = 'There was a problem refreshing your academic plan information.  Please contact your administrator'
    end
    redirect_to admin_edit_submission_path(@submission.id)
  end

  def send_email_reminder
    fail_message = 'Email was not sent. Email reminders may only be sent once a day; a reminder was recently sent to this committee member.'.html_safe
    success_message = 'Email successfully sent.'.html_safe
    @submission = Submission.find(params[:id])
    @committee_member = @submission.committee_members.find(params[:committee_member_id])
    return render plain: fail_message unless @committee_member.reminder_email_authorized?

    WorkflowMailer.send_committee_review_reminders(@submission, @committee_member)
    render plain: success_message
  end

  private

  def most_relevant_file_links
    links = []
    if @submission.final_submission_files.any?
      @submission.final_submission_files.map do |f|
        link = link_to f.asset_identifier, admin_final_submission_file_path(f.id), 'target': '_blank', 'data-no-turbolink': true
        links.push(link)
      end
    end
    links.join(" ")
  end
end
