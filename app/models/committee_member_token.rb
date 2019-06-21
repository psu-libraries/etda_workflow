class CommitteeMemberToken < ApplicationRecord
  validates :authentication_token, presence: true

  belongs_to :committee_member, optional: true

  def authentication_token=(new_token)
    self[:authentication_token] = new_token
    self.token_created_on = Date.today if new_token.present?
  end
end
