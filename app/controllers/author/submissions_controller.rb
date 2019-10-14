class Author::SubmissionsController < AuthorController
  class MissingLionPathRecordError < StandardError; end
  before_action :find_submission, except: [:index, :new, :create, :published_submissions_index]

  def index
    @view = Author::SubmissionsIndexView.new(@author)
    # TODO: Flash to be removed after 1 year of digital signatures
    flash.now[:notice] = "Effective immediately, this site now includes the Digital Signatures feature.  This gives committee members the ability to digitally approve submissions through this site.  Graduate students submitting a thesis or dissertation through the Electronic Thesis and Dissertation Application will have their thesis and dissertation submission digitally signed by their committees via the eTD application.  This capability allows a student to securely share their final document with the committee members and allows committee members the ability to review the document and give their approval electronically.</br></br>Electronic signatures will replace the Signatory Form only.  All other supporting materials must still be submitted to the Office of Theses and Dissertations.</br></br><a target='_blank' href='https://news.psu.edu/story/581573/2019/07/29/thesis-dissertation-submissions-be-digitally-signed-starting-fall-2019'>Penn State News: Thesis, dissertation submissions to be digitally signed starting in fall 2019</a>".html_safe if current_partner.graduate?
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
    raise CommitteeMember::ProgramHeadMissing if @submission.head_of_program_is_approving? && CommitteeMember.head_of_program(@submission.id).blank?
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
    status_giver.can_upload_final_submission_files?
    @submission.update_attributes!(final_submission_params)
    @submission.update_attribute :publication_release_terms_agreed_to_at, Time.zone.now
    if @submission.status == 'waiting for committee review rejected'
      current_partner.honors? ? status_giver.can_waiting_for_committee_review? : status_giver.can_waiting_for_final_submission?
      current_partner.honors? ? status_giver.waiting_for_committee_review! : status_giver.waiting_for_final_submission_response!
      OutboundLionPathRecord.new(submission: @submission).report_status_change
      @submission.reset_committee_reviews
      @submission.update_final_submission_timestamps!(Time.zone.now)
      redirect_to author_root_path
      WorkflowMailer.final_submission_received(@submission).deliver
      flash[:notice] = 'Final submission files uploaded successfully.'
      return
    elsif @submission.status == 'collecting final submission files rejected' && current_partner.honors?
      status_giver.can_waiting_for_final_submission?
      status_giver.waiting_for_final_submission_response!
      OutboundLionPathRecord.new(submission: @submission).report_status_change
      @submission.update_final_submission_timestamps!(Time.zone.now)
      redirect_to author_root_path
      WorkflowMailer.final_submission_received(@submission).deliver
      flash[:notice] = 'Final submission files uploaded successfully.'
      return
    end
    if current_partner.honors?
      status_giver.can_waiting_for_committee_review?
      status_giver.waiting_for_committee_review!
      @submission.reset_committee_reviews
      @submission.send_initial_committee_member_emails unless approval_status == 'approved'
    else
      status_giver.can_waiting_for_final_submission?
      status_giver.waiting_for_final_submission_response!
    end
    OutboundLionPathRecord.new(submission: @submission).report_status_change
    @submission.update_final_submission_timestamps!(Time.zone.now)
    redirect_to author_root_path
    WorkflowMailer.final_submission_received(@submission).deliver_now
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
    @committee_member = @submission.committee_members.find(params[:committee_member_id])
    if @committee_member.reminder_email_authorized?
      if @committee_member.committee_role.name == 'Special Member' || @committee_member.committee_role.name == 'Special Signatory'
        WorkflowMailer.special_committee_review_request(@submission, @committee_member).deliver
      else
        WorkflowMailer.committee_member_review_reminder(@submission, @committee_member).deliver
      end
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
                                         :federal_funding,
                                         invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy],
                                         final_submission_files_attributes: [:asset, :asset_cache, :submission_id, :id, :_destroy])
    end
end
