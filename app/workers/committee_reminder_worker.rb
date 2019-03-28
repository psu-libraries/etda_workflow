class CommitteeReminderWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'mailers'

  def perform(submission_id, recipient_email_address)
    submission = Submission.find_by(submission_id)
    WorkflowMailer.committee_member_review_reminder(submission, recipient_email_address).deliver
  end
end
