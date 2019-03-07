class CommitteeReminderWorker
  include Sidekiq::Worker

  def perform(submission_id, recipient_email_address)
    WorkflowMailer.committee_member_reminder(submission_id, recipient_email_address).deliver
  end
end
