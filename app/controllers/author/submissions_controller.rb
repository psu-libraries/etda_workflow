class Author::SubmissionsController < AuthorController
  before_action :find_submission, except: [:index, :new, :create, :published_submissions_index]

  def index
    @view = Author::SubmissionsIndexView.new(@author)
    # TODO: Flash to be removed after 1 year of digital signatures
    flash.now[:notice] = "Effective immediately, this site now includes the Digital Signatures feature.  This gives committee members the ability to digitally approve submissions through this site.  Graduate students submitting a thesis or dissertation through the Electronic Thesis and Dissertation Application will have their thesis and dissertation submission digitally signed by their committees via the eTD application.  This capability allows a student to securely share their final document with the committee members and allows committee members the ability to review the document and give their approval electronically.</br></br>Electronic signatures will replace the Signatory Form only.  All other supporting materials must still be submitted to the Office of Theses and Dissertations.</br></br><a target='_blank' href='https://news.psu.edu/story/581573/2019/07/29/thesis-dissertation-submissions-be-digitally-signed-starting-fall-2019'>Penn State News: Thesis, dissertation submissions to be digitally signed starting in fall 2019</a>".html_safe if current_partner.graduate?
  end

  def new
    @submission = @author.submissions.new
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

  def edit
    @submission = find_submission
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
    @submission.update!(standard_program_params)
    redirect_to author_root_path
    flash[:notice] = 'Program information updated successfully'
  rescue ActiveRecord::RecordInvalid
    flash[:alert] = 'Oops! You may have submitted invalid program information data. Please check that your program information is correct.'
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
    missing_head_redirect
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
  rescue CommitteeMember::ProgramHeadMissing
    redirect_to author_submission_head_of_program_path(@submission)
    flash[:alert] = 'In order to proceed to the final submission stage, you must input the head/chair of your graduate program here.'
  end

  def update_final_submission
    @submission = find_submission
    approval_status = ApprovalStatus.new(@submission).status
    status_giver = SubmissionStatusGiver.new(@submission)
    submit_service = FinalSubmissionSubmitService.new(@submission, status_giver,
                                                      approval_status, final_submission_params)
    submit_service.submit_final_submission
    redirect_to author_root_path
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

    def missing_head_redirect
      raise CommitteeMember::ProgramHeadMissing if program_head_missing
    end

    def program_head_missing
      @submission.head_of_program_is_approving? && CommitteeMember.head_of_program(@submission).blank?
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
                                         invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy],
                                         final_submission_files_attributes: [:asset, :asset_cache, :submission_id, :id, :_destroy])
    end
end
