class Author::SubmissionsController < AuthorController
  before_action :find_submission, except: [:index, :new, :create, :published_submissions_index]

  def index
    @view = Author::SubmissionsIndexView.new(@author)
  end

  def new
    if params[:admin_lionpath]
      return redirect_to '/401' unless admin?

      degree_type = DegreeType.find_by(slug: params[:degree_type])
      Lionpath::LionpathSubmissionGenerator.new(current_remote_user, degree_type).create_submission
      redirect_to author_submissions_path
    else
      @submission = @author.submissions.new
    end
  end

  def create
    @submission = @author.submissions.new(standard_program_params)
    @submission.author_edit = true
    @submission.save!
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.collecting_committee!
    redirect_to author_root_path
    flash[:notice] = 'Program information saved successfully'
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = 'Oops! You may have submitted invalid program information data. Please check that your program information is correct.'
    render :new
  rescue SubmissionStatusGiver::InvalidTransition
    redirect_to author_root_path
    flash[:alert] = 'Oops! You may have submitted invalid program information data. Please check that your program information is correct.'
  end

  def acknowledge
    @submission = find_submission
  end

  def acknowledge_update
    @submission = find_submission
    #todo: validate they are filled
    if @submission.update(:author_edit => false, :acknowledgment_page_viewed_at => DateTime.now)
      redirect_to edit_author_submission_path(@submission)
    else
      # todo show error
      puts 'something is wrong'
    end
  end

  def edit
    @submission = find_submission
    if @submission.acknowledgment_page_viewed_at.nil?
      redirect_to author_submission_acknowledge_path(@submission)
    end
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_update_program_information?
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
    redirect_to author_root_path
  end

  def update
    @submission = find_submission
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_update_program_information?
    @submission.update!(standard_program_params)
    status_giver.collecting_committee! if @submission.status_behavior.collecting_program_information?
    redirect_to author_root_path
    flash[:notice] = 'Program information updated successfully'
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = 'Oops! You may have submitted invalid program information data. Please check that your program information is correct.'
    render :edit
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
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
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
  end

  def edit_final_submission
    @submission = find_submission
    FeePaymentService.new(@submission).fee_is_paid? if current_partner.graduate? && !development_instance?

    @view = Author::FinalSubmissionFilesView.new(@submission)
    default_open_access(@submission)
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_upload_final_submission_files?
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
  rescue FeePaymentService::FeeNotPaid
    redirect_to author_root_path
    flash[:fee_dialog] = I18n.t("graduate.fee_message.#{@submission.degree.degree_type.slug}.message").html_safe
  rescue RuntimeError
    redirect_to author_root_path
    flash[:alert] = "An error occurred while processing your request.  Please contact an administrator using the 'Contact Us' tab above, or try again at another time."
  end

  def update_final_submission
    @submission = find_submission
    status_giver = SubmissionStatusGiver.new(@submission)
    submit_service = FinalSubmissionSubmitService.new(@submission, status_giver, final_submission_params)
    submit_service.submit_final_submission
    redirect_to author_root_path
    flash[:notice] = 'Final submission files uploaded successfully.'
  rescue ActiveRecord::RecordInvalid
    @view = Author::FinalSubmissionFilesView.new(@submission)
    render :edit_final_submission
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
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
    flash[:alert] = t("#{current_partner.id}.partner.not_allowed_alert")
  end

  def published_submissions_index
    @view = Author::PublishedSubmissionsIndexView.new(@author)
    render 'published_submissions_index'
  end

  def send_email_reminder
    @committee_member = @submission.committee_members.find(params[:committee_member_id])
    if @committee_member.reminder_email_authorized?
      WorkflowMailer.send_committee_review_reminders(@submission, @committee_member)
      redirect_to author_submission_committee_review_path(@submission.id)
      flash[:notice] = 'Email successfully sent.'
    else
      redirect_to author_submission_committee_review_path(@submission.id)
      flash[:alert] = 'Email was not sent.  Email reminders may only be sent once a day; a reminder was recently sent to this committee member.'
    end
  end

  private

    def default_open_access(submission)
      submission.access_level = 'open_access' if (current_partner.honors? || current_partner.milsch?) && submission.access_level.blank?
    end

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

    def acknowledge_params
      def standard_program_params
        params.require(:submission).permit(:acknowledgment_page_viewed_at)
      end
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
                                         :federal_funding,
                                         :proquest_agreement,
                                         invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy],
                                         final_submission_files_attributes: [:asset, :asset_cache, :submission_id, :id, :_destroy])
    end
end
