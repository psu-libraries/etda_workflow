class ExternalApp < ApplicationRecord
  has_many :api_tokens, dependent: :destroy

  validates :name, uniqueness: true, presence: true
end
