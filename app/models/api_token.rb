# frozen_string_literal: true

class ApiToken < ApplicationRecord
  belongs_to :external_app

  before_create :set_token

  def record_usage
    update_column(:last_used_at, Time.zone.now)
  end

  private

    def set_token
      self.token ||= SecureRandom.hex(48)
    end
end
