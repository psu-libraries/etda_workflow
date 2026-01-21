class ExternalApp < ApplicationRecord
  has_many :api_tokens, dependent: :destroy

  validates :name, uniqueness: true, presence: true

  class PdfAccessibilityApi
    NAME = 'PDF Accessibility API'

    def self.build
      ExternalApp.find_or_create_by(name: NAME) do |app|
        app.api_tokens.build
      end
    end
  end

  def self.pdf_accessibility_api
    PdfAccessibilityApi.build
  end

  def token
    api_tokens.first.token
  end
end
