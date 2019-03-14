class ApproverAbility
  include CanCan::Ability
  def initialize(approver, submission_id)
    return if approver.blank?

    can [:view, :edit], CommitteeMember, committee_member: { access_id: approver.access_id }
    can [:read], FinalSubmissionFile, submission: { id: submission_id }
  end
end