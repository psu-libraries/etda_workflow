class CommitteeReminderWorker
  include Sidekiq::Worker

  def perform(submission_id, recipient_email_address)
    submission = Submission.find_by(submission_id)
    WorkflowMailer.committee_member_reminder(submission, recipient_email_address).deliver
  end
end
