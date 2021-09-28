class SeventhDayEvaluationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'committee_evaluations'

  def perform(submission_id)
    submission = Submission.find(submission_id)
    return unless submission.status_behavior.waiting_for_committee_review?

    approval_status = submission.approval_status_behavior.status
    if approval_status == 'pending'
      if current_partner.graduate?
        graduate_emails(submission)
      else
        non_graduate_emails(submission)
      end
    else
      SubmissionStatusUpdaterService.new(submission).update_status_from_committee
    end
  end

  private

    def graduate_emails(submission)
      WorkflowMailer.seventh_day_to_chairs(submission).deliver
      WorkflowMailer.seventh_day_to_author(submission).deliver
    end

    def non_graduate_emails(submission)
      submission.voting_committee_members.each do |cm|
        WorkflowMailer.send_committee_review_reminders(submission, cm) if %w[approved rejected].exclude? cm.status
      end
    end
end
