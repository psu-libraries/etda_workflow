class CommitteeReminderWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'mailers'

  def perform(submission_id, committee_member_id)
    submission = Submission.find_by(id: submission_id)
    committee_member = CommitteeMember.find_by(id: committee_member_id)
    WorkflowMailer.committee_member_review_reminder(submission, committee_member).deliver
  end
end
