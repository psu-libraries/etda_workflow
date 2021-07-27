class SubmissionStatusUpdaterService
  attr_accessor :submission

  def initialize(submission)
    @submission = submission
  end

  def update_status_from_committee
    if submission.status == 'waiting for committee review'
      update_status_from_base_committee
    elsif submission.status == 'waiting for head of program review'
      update_status_from_head_of_program
    end
  end

  private

  def update_status_from_base_committee
    submission_status = ApprovalStatus.new(submission)
    status_giver = SubmissionStatusGiver.new(submission)
    if submission_status.status == 'approved'
      if submission.head_of_program_is_approving?
        status_giver.can_waiting_for_head_of_program_review?
        status_giver.waiting_for_head_of_program_review!
        submission.update_attribute(:committee_review_accepted_at, DateTime.now)
        WorkflowMailer.send_head_of_program_review_request(submission, submission_status)
        update_status_from_head_of_program
      else
        status_giver.can_waiting_for_final_submission_response?
        status_giver.waiting_for_final_submission_response!
        submission.update_attribute(:committee_review_accepted_at, DateTime.now)
        WorkflowMailer.send_committee_approved_email(submission)
      end
    elsif submission_status.status == 'rejected'
      status_giver.can_waiting_for_committee_review_rejected?
      status_giver.waiting_for_committee_review_rejected!
      submission.update_attribute(:committee_review_rejected_at, DateTime.now)
      WorkflowMailer.send_committee_rejected_emails(submission)
    end
  end

  def update_status_from_head_of_program
    submission_head_of_program_status = ApprovalStatus.new(submission).head_of_program_status
    status_giver = SubmissionStatusGiver.new(submission)
    if submission_head_of_program_status == 'approved'
      status_giver.can_waiting_for_final_submission_response?
      status_giver.waiting_for_final_submission_response!
      submission.update_attribute(:head_of_program_review_accepted_at, DateTime.now)
      WorkflowMailer.send_committee_approved_email(submission)
    elsif submission_head_of_program_status == 'rejected'
      status_giver.can_waiting_for_committee_review_rejected?
      status_giver.waiting_for_committee_review_rejected!
      submission.update_attribute(:head_of_program_review_rejected_at, DateTime.now)
      WorkflowMailer.send_committee_rejected_emails(submission)
    end
  end
end