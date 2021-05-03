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
      WorkflowMailer.send_pending_returned_emails(submission)
      status_giver.waiting_for_committee_review_rejected!
      submission.update committee_review_rejected_at: DateTime.now
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
    FinalSubmissionParams.call(params)
  end
end
