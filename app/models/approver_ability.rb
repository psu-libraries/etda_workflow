class ApproverAbility
  include CanCan::Ability
  def initialize(approver, submission_id)
    @submission = Submission.find(submission_id)
    return if approver.blank?

    can [:view, :read, :edit], @submission.committee_members, access_id: approver.access_id
  end
end