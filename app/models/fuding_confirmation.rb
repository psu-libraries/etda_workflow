class FundingConfirmation
  include ActiveModel::Model

  attr_accessor :training_funding_confirmation, :other_funding_confirmation, :admin_funding_confirmation

  validates :training_funding_confirmation, :other_funding_confirmation, :admin_funding_confirmation, acceptance: true
end
