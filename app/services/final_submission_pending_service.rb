class FinalSubmissionPendingService
  attr_accessor :submission, :status_giver, :params, :current_remote_user

  def initialize(submission, params, current_remote_user)
    @submission = submission
    @status_giver = SubmissionStatusGiver.new(submission)
    @params = params
    @current_remote_user = current_remote_user
  end

  def respond
    status_giver.can_committee_review_admin_response?
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    if params[:return_to_author]
      status_giver.can_waiting_for_committee_review_rejected?
      status_giver.waiting_for_committee_review_rejected!
      submission.update committee_review_rejected_at: DateTime.now
      WorkflowMailer.send_pending_returned_emails(submission)
      { msg: "The submission was successfully returned to the student for resubmission.", redirect_to: submission_path }
    else
      submission.update_status_from_committee
      { msg: "The submission was successfully updated.", redirect_to: submission_path }
    end
  end

  private

  def submission_path
    Rails.application.routes.url_helpers.admin_edit_submission_path(submission)
  end

  def final_submission_params
    params.require(:submission).permit(
      :semester,
      :year,
      :author_id,
      :program_id,
      :degree_id,
      :title,
      :allow_all_caps_in_title,
      :format_review_notes,
      :admin_notes,
      :final_submission_notes,
      :defended_at,
      :abstract,
      :access_level,
      :is_printed,
      :has_agreed_to_terms,
      :has_agreed_to_publication_release,
      :lion_path_degree_code,
      :restricted_notes,
      :federal_funding,
      committee_members_attributes: [:id, :committee_role_id, :name, :email, :status, :notes, :is_required,
                                     :is_voting, :federal_funding_used, :_destroy],
      format_review_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      final_submission_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      keywords_attributes: [:word, :id, :_destroy],
      invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy]
    )
  end
end
