class SeventhDayEvaluationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'committee_evaluations'

  def perform(submission_id, final_reminder_sent = false)
    submission = Submission.find(submission_id)
    return unless submission.status_behavior.waiting_for_committee_review?

    approval = submission.approval_status_behavior
    if approval.status == 'pending'
      if current_partner.graduate? && submission.degree_type.slug == 'dissertation'
        dissertation_emails(submission)
      else
        non_dissertation_emails(submission)
      end
    elsif approval.approved_with_non_voters? && current_partner.graduate? && final_reminder_sent == false
      approval_reminder_emails(submission)
      SeventhDayEvaluationWorker.perform_in(7.days, submission_id, true)
    else
      SubmissionStatusUpdaterService.new(submission).update_status_from_committee
    end
  end

  private

    def dissertation_emails(submission)
      WorkflowMailer.seventh_day_to_chairs(submission).deliver
      WorkflowMailer.seventh_day_to_author(submission).deliver
    end

    def non_dissertation_emails(submission)
      submission.voting_committee_members.each do |cm|
        WorkflowMailer.send_committee_review_reminders(submission, cm) if %w[approved rejected].exclude? cm.status
      end
    end

    def approval_reminder_emails(submission)
      submission.voting_committee_members.each do |cm|
        WorkflowMailer.send_nonvoting_approval_reminders(submission, cm) if %w[approved rejected].exclude? cm.status
      end
    end
end
