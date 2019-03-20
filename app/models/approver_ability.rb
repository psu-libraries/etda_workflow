class ApproverAbility
  include CanCan::Ability
  def initialize(approver, _committee_member_id)
    return if approver.blank?

    can [:view, :read, :edit], CommitteeMember, access_id: approver.access_id
  end
end