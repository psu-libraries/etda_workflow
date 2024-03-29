class CommitteeReminderWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'mailers'

  def perform(submission_id, committee_member_id)
    submission = Submission.find(submission_id)
    committee_member = CommitteeMember.find(committee_member_id)
    return unless submission.committee_members.map(&:id).include?(committee_member.id)

    return unless committee_member.reminder_email_authorized?

    return if committee_member.status.present? || submission.status_behavior.beyond_waiting_for_head_of_program_review?

    WorkflowMailer.send_committee_review_reminders(submission, committee_member)
  end
end
