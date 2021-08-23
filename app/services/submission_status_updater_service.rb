class SubmissionStatusUpdaterService
  attr_accessor :submission, :approval_status, :status_giver

  def initialize(submission)
    @submission = submission
    @approval_status = submission.approval_status_behavior
    @status_giver = SubmissionStatusGiver.new(submission)
  end

  def update_status_from_committee
    if submission.status == 'waiting for advisor review'
      update_status_from_advisor
    elsif submission.status == 'waiting for committee review'
      update_status_from_base_committee
    elsif submission.status == 'waiting for head of program review'
      update_status_from_head_of_program
    end
  end

  private

  def update_status_from_advisor
    if submission.advisor.status == 'approved' && !funding_discrepancy?
      send_to_committee_review
      update_status_from_base_committee
    elsif submission.advisor.status == 'approved' && funding_discrepancy?
      send_to_committee_review_rejected
      WorkflowMailer.advisor_funding_discrepancy(submission).deliver
      submission.update_attribute(:committee_review_rejected_at, DateTime.now)
    elsif submission.advisor.status == 'rejected'
      send_to_committee_review_rejected
      WorkflowMailer.advisor_rejected(submission).deliver
      submission.update_attribute(:committee_review_rejected_at, DateTime.now)
    end
  end

  def update_status_from_base_committee
    if approval_status.status == 'approved'
      if submission.head_of_program_is_approving?
        send_to_program_head
        update_status_from_head_of_program
      else
        send_to_final_submission_response
        submission.update_attribute(:committee_review_accepted_at, DateTime.now)
      end
    elsif approval_status.status == 'rejected'
      send_to_committee_review_rejected
      WorkflowMailer.send_committee_rejected_emails(submission)
      submission.update_attribute(:committee_review_rejected_at, DateTime.now)
    end
  end

  def update_status_from_head_of_program
    if approval_status.head_of_program_status == 'approved'
      send_to_final_submission_response
      submission.update_attribute(:head_of_program_review_accepted_at, DateTime.now)
    elsif approval_status.head_of_program_status == 'rejected'
      send_to_committee_review_rejected
      WorkflowMailer.send_committee_rejected_emails(submission)
      submission.update_attribute(:head_of_program_review_rejected_at, DateTime.now)
    end
  end

  def send_to_committee_review
    status_giver.can_waiting_for_committee_review?
    status_giver.waiting_for_committee_review!
    submission.committee_review_requests_init
  end

  def send_to_committee_review_rejected
    status_giver.can_waiting_for_committee_review_rejected?
    status_giver.waiting_for_committee_review_rejected!
  end

  def send_to_final_submission_response
    status_giver.can_waiting_for_final_submission_response?
    status_giver.waiting_for_final_submission_response!
    WorkflowMailer.send_committee_approved_email(submission)
  end

  def send_to_program_head
    status_giver.can_waiting_for_head_of_program_review?
    status_giver.waiting_for_head_of_program_review!
    submission.update_attribute(:committee_review_accepted_at, DateTime.now)
    submission.program_head.update approval_started_at: DateTime.now
    return if approval_status.head_of_program_status == 'approved'

    WorkflowMailer.send_head_of_program_review_request(submission, approval_status)
  end

  def funding_discrepancy?
    return false if submission.advisor.federal_funding_used.nil?

    submission.federal_funding != submission.advisor.federal_funding_used
  end
end
