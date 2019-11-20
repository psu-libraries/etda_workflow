class CommitteeReminderWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'mailers'

  def perform(submission_id, committee_member_id)
    submission = Submission.find(submission_id)
    committee_member = CommitteeMember.find(committee_member_id)
    return unless submission.committee_members.map(&:id).include? committee_member.id

    return if committee_member.status == 'approved' || committee_member.status == 'rejected'

    if committee_member.committee_member_token.present?
      WorkflowMailer.special_committee_review_request(submission, committee_member).deliver
    else
      WorkflowMailer.committee_member_review_reminder(submission, committee_member).deliver
    end
  end
end
