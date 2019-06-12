class CommitteeMemberToken < ApplicationRecord
  validates :authentication_token, presence: true

  belongs_to :committee_member, optional: true
end