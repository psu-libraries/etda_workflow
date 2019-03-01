class BulkEmailHandler
  include Sidekiq::Worker

  def queue_committee_member_approval_started(recipient, content)
    WorkflowMailer.committee_member_approval_started(recipient, content).deliver_now
  end

  def queue_committtee_member_reminder(recipient, content)
    WorkflowMailer.committee_member_approval_reminder(recipient, content).deliver_now
  end

  def queue_committee_member_rejection(recipient, content)
    WorkflowMailer.committee_member_rejection(recipient, content).deliver_now
  end

  def queue_committee_member_approval(recipient, content)
    WorkflowMailer.committee_member_rejection(recipient, content).deliver_now
  end

  def queue_committee_member_rejection_admin(recipient, content)
    WorkflowMailer.committee_member_rejection_admin(recipient, content).deliver_now
  end
end
