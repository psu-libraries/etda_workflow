class FinalSubmissionApprovedService
  attr_accessor :submission, :current_remote_user, :status_giver, :final_submission_params

  def initialize(submission, current_remote_user, status_giver, final_submission_params)
    @submission = submission
    @current_remote_user = current_remote_user
    @status_giver = status_giver
    @final_submission_params = final_submission_params
  end

  def release_updated
    # Editing a submission that is waiting to be released for publication
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    { msg: 'The submission was successfully updated.', redirect_path: admin_edit_sub_path }
  end

  def release_rejected
    # Move back to Waiting for final submission approval (final submission submitted)
    # No file path changes necessary here; submission not released yet; files are still in workflow
    status_giver.can_remove_from_waiting_to_be_released?
    status_giver.waiting_for_final_submission_response!
    # @submission.update_attribute :final_submission_rejected_at, Time.zone.now  #this causes it to go into final rejected - WAS ERROR
    # submission.update_attributes! final_submission_params
    submission.final_submission_approved_at = nil
    submission.final_submission_rejected_at = nil
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    { msg: 'Submission was removed from waiting to be released', redirect_path: admin_approved_sub_index_path }
  end

  def release_sent_to_hold
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    submission.placed_on_hold_at = DateTime.now
    submission.save
    status_giver.can_waiting_in_final_submission_on_hold?
    status_giver.waiting_in_final_submission_on_hold!
    { msg: "The submission was successfully placed on hold.", redirect_path: admin_hold_sub_index_path }
  end

  def release_remove_hold
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    submission.removed_hold_at = DateTime.now
    submission.save
    status_giver.can_waiting_for_publication_release?
    status_giver.waiting_for_publication_release!
    msg = "The submission was successfully removed from its hold and is waiting to be released."
    { msg: msg, redirect_path: admin_approved_sub_index_path }
  end

  private

  def admin_edit_sub_path
    url_helpers.admin_edit_submission_path(submission.id.to_s)
  end

  def admin_hold_sub_index_path
    url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_on_hold')
  end

  def admin_approved_sub_index_path
    url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_approved')
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
