class Author::CommitteeMembersController < AuthorController
  before_action :find_submission

  def new
    status_giver.can_provide_new_committee?
    @submission.build_committee_members_for_partners
    render :form
  rescue SubmissionStatusGiver::AccessForbidden
    redirect_to author_root_path
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
  end

  def create
    status_giver.can_provide_new_committee?
    @submission.save!(submission_params)
    status_giver.collecting_format_review_files!
    @submission.update_attribute :committee_provided_at, Time.zone.now
    flash[:notice] = 'Committee saved successfully'
    redirect_to author_root_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.message
    render :new
  rescue SubmissionStatusGiver::AccessForbidden
    flash.now[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
    redirect_to author_root_path
  end

  def edit
    status_giver.can_update_committee?
    render :form
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
    redirect_to author_root_path
  end

  def update
    @submission.update_attributes!(submission_params)
    status_giver.collecting_format_review_files! if @submission.status_behavior.collecting_committee?
    @submission.update_attribute :committee_provided_at, Time.zone.now

    flash[:notice] = 'Committee updated successfully'
    if params[:commit] == "Save and Return to Dashboard" || params[:commit] == 'Verify Committee'
      redirect_to author_root_path
    else
      redirect_to edit_author_submission_committee_members_path(@submission)
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.message
    render :form
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
    redirect_to author_root_path
  end

  def show
    status_giver.can_create_or_edit_committee?
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'You have not completed the required steps to review your committee yet'
    redirect_to author_root_path
  end

  def refresh
    @submission.author.populate_lion_path_record(@submission.author.psu_idn, @submission.author.access_id)
    if @submission.academic_plan.committee_members_refresh
      flash[:notice] = 'Committee members successfully refreshed from Lion Path.'
    else
      flash[:alert] = 'Unable to refresh committee member information from Lion Path.'
    end
    render :show
  end

  private

    def status_giver
      SubmissionStatusGiver.new(@submission)
    end

    def find_submission
      @submission = current_author.submissions.find(params[:submission_id])
      @presenter = Author::CommitteeFormView.new(@submission)
    end

    def submission_params
      params.require(:submission).permit(committee_members_attributes: [:id, :name, :email, :committee_role_id, :is_required, :is_voting, :lion_path_degree_code, :_destroy])
    end
end
