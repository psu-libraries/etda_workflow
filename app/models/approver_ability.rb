class ApproverAbility
  include CanCan::Ability
  def initialize(approver, _committee_member_id)
    return if approver.blank?

    can [:view, :read, :edit], CommitteeMember, approver_id: approver.id
  end
end
