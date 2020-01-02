class CommitteeReminderWorker
  include Sidekiq::Worker
  include MailerActionService
  sidekiq_options queue: 'mailers'

  def perform(submission_id, committee_member_id)
    submission = Submission.find(submission_id)
    committee_member = CommitteeMember.find(committee_member_id)
    return unless submission.committee_members.map(&:id).include? committee_member.id

    return if committee_member.status == 'approved' || committee_member.status == 'rejected'

    send_committee_review_reminders(submission, committee_member)
  end
end
