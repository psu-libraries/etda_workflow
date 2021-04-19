class FinalSubmissionSubmittedService
  attr_accessor :submission, :current_remote_user, :status_giver, :final_submission_params

  def initialize(submission, current_remote_user, status_giver, final_submission_params)
    @submission = submission
    @current_remote_user = current_remote_user
    @status_giver = status_giver
    @final_submission_params = final_submission_params
  end

  def final_submission_approved
    status_giver.can_waiting_for_publication_release?
    status_giver.waiting_for_publication_release!
    @submission.update! final_submission_approved_at: DateTime.now
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    WorkflowMailer.send_final_emails(submission)
    "The submission\'s final submission information was successfully approved."
  end

  def final_submission_rejected
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    submission.has_agreed_to_publication_release = false
    submission.publication_release_terms_agreed_to_at = nil
    submission.has_agreed_to_terms = false
    submission.final_submission_rejected_at = Time.zone.now
    submission.save
    status_giver.can_respond_to_final_submission?
    status_giver.collecting_final_submission_files_rejected!
    WorkflowMailer.send_final_submission_rejected_email(@submission)
    "The submission\'s final submission information was successfully rejected and returned to the author for revision."
  end

  def final_rejected_send_committee
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    submission.save
    status_giver.can_waiting_for_committee_review?
    status_giver.waiting_for_committee_review!
    submission.reset_committee_reviews
    submission.committee_review_requests_init
    WorkflowMailer.sent_to_committee(@submission).deliver
    "The submission was successfully returned to the committee review stage and the committee was notified to visit the site for review."
  end

  def final_rejected_send_dept_head
    return "This submission does not have a program head." if submission.program_head.blank?

    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    submission.save
    status_giver.can_waiting_for_head_of_program_review?
    status_giver.waiting_for_head_of_program_review!
    submission.reset_program_head_review
    WorkflowMailer.committee_member_review_request(@submission, @submission.program_head).deliver
    "The submission was successfully returned to the program head review stage and the program head was notified to visit the site for review."
  end

  def final_submission_updated
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    " Final submission information was successfully edited by an administrator"
  end
end
