# frozen_string_literal: true

FactoryBot.define do
  factory :approval_configuration do |_ac|
    approval_deadline_on { Date.yesterday }
    use_percentage { 0 }
    configuration_threshold { 1 }
    email_authors { 0 }
    email_admins { 0 }
    degree_type
  end
end
