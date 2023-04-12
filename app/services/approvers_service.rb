class ApproversService
  attr_accessor :approver

  def initialize(approver)
    @approver = approver
  end

  def update_committee_w_token(committee_member_token)
    committee_member_init = committee_member_token.committee_member
    committee_members = CommitteeMember.where(email: committee_member_init.email)
    committee_members.each do |committee_member|
      committee_member.update_attribute :access_id, approver.access_id
      approver.committee_members << committee_member
      committee_member.committee_member_token ? committee_member.committee_member_token.destroy! : next
    end
    approver.save!
  end

  def update_committee_w_access_id
    committee_members = CommitteeMember.where(access_id: approver.access_id)
    committee_members.each do |committee_member|
      next if committee_member.approver_id == approver.id

      committee_member.approver_id = approver.id
      committee_member.save!
    end
  end
end
