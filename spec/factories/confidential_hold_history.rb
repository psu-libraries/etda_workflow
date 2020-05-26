# frozen_string_literal: true

FactoryBot.define do
  factory :confidential_hold_history do
    set_by { "login_controller" }
    set_at { DateTime.now }
    removed_by { nil }
    removed_at { nil }
    author
  end
end
