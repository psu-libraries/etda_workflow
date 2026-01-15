class ExternalApp < ApplicationRecord
  has_many :api_tokens,
          dependent: :destroy,
          foreign_key: 'application_id',
          inverse_of: 'application'

  validates :name,
    presence: true,
    uniqueness: true
end
