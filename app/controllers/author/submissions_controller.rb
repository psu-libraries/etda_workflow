class Author::SubmissionsController < AuthorController
  class MissingLionPathRecordError < StandardError; end
  before_action :find_submission, except: [:index, :new, :create, :published_submissions_index]

  def index
    @view = Author::SubmissionsIndexView.new(@author)
  end

  def new
    if InboundLionPathRecord.active? && !@author.academic_plan?
      redirect_to author_root_path
      flash[:error] = "Unable to find Lion Path thesis information for #{@author.first_name} #{@author.last_name}. Please contact your administrator."
    end
    @view = Author::ProgramInformationView.new(nil)
    @submission = @author.submissions.new
  end

  def create
    @submission = if InboundLionPathRecord.active?
      @author.submissions.new(lionpath_program_params)
                  else
      @author.submissions.new(standard_program_params)
                  end
    @submission.author_edit = true

    @submission.save!
    @submission.update_attribute(:defended_at, LionPath::Crosswalk.convert_to_datetime(params[:submission][:defended_at])) if @submission.using_lionpath? && current_partner.graduate?
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.collecting_committee!
    OutboundLionPathRecord.new(submission: @submission).report_status_change
    redirect_to author_root_path
    flash[:notice] = 'Program information saved successfully'
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = 'Oops! You may have submitted invalid program information data. Please check that your program information is correct.'
    @view = Author::ProgramInformationView.new(nil)
    render :new
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to author_root_path
    flash[:alert] = 'Oops! You may have submitted invalid program information data. Please check that your program information is correct.'
  end

  def edit
    @submission = find_submission
    if InboundLionPathRecord.active? && !@author.academic_plan?
      redirect_to author_root_path
      flash[:error] = "Unable to find Lion Path thesis information for #{@author.first_name} #{@author.last_name}.  Please contact your administrator"
    end
    @view = Author::ProgramInformationView.new(@submission)
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_update_program_information?
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
    redirect_to author_root_path
  end

  def update
    @submission = find_submission
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_update_program_information?
    outbound_lionpath_record = OutboundLionPathRecord.new(submission: @submission, original_title: @submission.title, original_alternate_email: @submission.author.alternate_email_address)
    if @submission.using_lionpath?
      @submission.update_attributes!(lionpath_program_params)
      @submission.update_attribute(:defended_at, LionPath::Crosswalk.convert_to_datetime(params[:submission][:defended_at])) if @submission.using_lionpath? && current_partner.graduate?
    else
      @submission.update_attributes!(standard_program_params)
    end
    outbound_lionpath_record.report_title_change
    redirect_to author_root_path
    flash[:notice] = 'Program information updated successfully'
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = 'Oops! You may have submitted invalid program information data. Please check that your program information is correct.'
    @view = Author::ProgramInformationView.new(@submission)
    render :edit
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
  end

  def destroy
    @submission = find_submission
    @submission.destroy
    flash[:notice] = "Submission deleted successfully."
    redirect_to author_root_path
  rescue StandardError
    flash[:alert] = "Can not delete submission."
    redirect_to author_root_path
  end

  def program_information
    @submission = find_submission
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_review_program_information?
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
  end

  def edit_final_submission
    @submission = find_submission
    @view = Author::FinalSubmissionFilesView.new(@submission)
    @submission.access_level = 'open_access' if (current_partner.honors? || current_partner.milsch?) && @submission.access_level.blank?
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_upload_final_submission_files?
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
  end

  def update_final_submission
    @submission = find_submission
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_upload_final_submission_files?
    @submission.update_attributes!(final_submission_params)
    @submission.update_attribute :publication_release_terms_agreed_to_at, Time.zone.now
    status_giver.waiting_for_committee_review!
    @submission.initial_committee_member_emails
    # kick off committee emails
    OutboundLionPathRecord.new(submission: @submission).report_status_change
    @submission.update_final_submission_timestamps!(Time.zone.now)
    redirect_to author_root_path
    WorkflowMailer.final_submission_received(@submission).deliver_now if current_partner.graduate?
    flash[:notice] = 'Final submission files uploaded successfully.'
  rescue ActiveRecord::RecordInvalid
    @view = Author::FinalSubmissionFilesView.new(@submission)
    render :edit_final_submission
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to author_root_path
    flash[:alert] = 'Oops! You may have submitted invalid format review data. Please check that your format review information is correct.'
  end

  def final_submission
    @submission = find_submission
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_review_final_submission_files?
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
  end

  def refresh
    return unless @submission.status_behavior.beyond_collecting_format_review_files?

    if @submission.author.inbound_lion_path_record.refresh_academic_plan(@submission)
      flash[:notice] = 'Academic plan information successfully refreshed from Lion Path.'
      redirect_to author_submission_program_information_path(@submission.id)
    else
      flash[:alert] = 'There was a problem refreshing your Academic Plan information from Lion Path.  Please contact your administrator.'
      redirect_to author_root_path
    end
  end

  def refresh_date_defended
    return unless @submission.status_behavior.beyond_collecting_final_submission_files?

    submission_defense_date = @submission.academic_plan.defense_date
    if submission_defense_date.present?
      @submission.defended_at = submission_defense_date
      @submission.save(validate: false)
      redirect_to author_submission_final_submission_path(@submission.id)
      flash[:notice] = 'Defense date successfully refreshed from Lion Path'
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to author_root_path
    flash[:alert] = 'There was a problem refreshing your defense date.  Please contact your administrator'
  end

  def published_submissions_index
    @view = Author::PublishedSubmissionsIndexView.new(@author)
    render 'published_submissions_index'
  end

  def send_email_reminder
    if @submission.committee_members.find(params[:committee_member_id]).reminder_email_authorized?
      WorkflowMailer.committee_member_review_reminder(@submission, @submission.committee_members.find(params[:committee_member_id])).deliver
      redirect_to author_submission_committee_review_path(@submission.id)
      flash[:notice] = 'Email successfully sent.'
    else
      redirect_to author_submission_committee_review_path(@submission.id)
      flash[:alert] = 'Email was not sent.  Email reminders may only be sent once a day; a reminder was recently sent to this committee member.'
    end
  end

  private

    def find_submission
      @submission = @author.submissions.find(params[:submission_id] || params[:id])
      return nil if @submission.nil?

      redirect_to '/401' unless @submission.author_id == current_author.id
      @submission.author_edit = true
      @submission
    end

    def find_author
      redirect_to '/login' if current_author.nil? || current_author.access_id.blank? && Rails.env.production?
      @author = current_author
    end

    def standard_program_params
      params.require(:submission).permit(:semester,
                                         :year,
                                         :author_id,
                                         :program_id,
                                         :degree_id,
                                         :title,
                                         :allow_all_caps_in_title)
    end

    def lionpath_program_params
      params.require(:submission).permit(:program_id,
                                         :degree_id,
                                         :title,
                                         :allow_all_caps_in_title,
                                         :author_id,
                                         :semester,
                                         :year,
                                         :defended_at,
                                         :lion_path_degree_code)
    end

    def final_submission_params
      params.require(:submission).permit(:title,
                                         :allow_all_caps_in_title,
                                         :semester,
                                         :year,
                                         :defended_at,
                                         :abstract,
                                         :access_level,
                                         :has_agreed_to_terms,
                                         :has_agreed_to_publication_release,
                                         :delimited_keywords,
                                         :lion_path_degree_code,
                                         :restricted_notes,
                                         invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy],
                                         final_submission_files_attributes: [:asset, :asset_cache, :submission_id, :id, :_destroy])
    end
end
