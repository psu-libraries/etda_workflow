class Approver < ApplicationRecord
  devise :oidc_authenticatable, :rememberable, :trackable, :registerable

  has_many :committee_members, dependent: :nullify

  validates :access_id, presence: true,
                        uniqueness: { case_sensitive: true }

  def self.current
    Thread.current[:approver]
  end

  def self.current=(approver)
    Thread.current[:approver] = approver
  end

  def self.status_merge(committee_member)
    committee_member.submission.committee_members.each do |member|
      next if member.id == committee_member.id

      member.update_attribute :status, committee_member.status if member.access_id == committee_member.access_id
    end
  end
end
