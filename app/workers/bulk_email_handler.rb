class BulkEmailHandler
  include Sidekiq::Worker

  def queue_mailer(recipient, content)
    WorkflowMailer.committee_member_approval_started(recipient, content).deliver_now
  end
end
