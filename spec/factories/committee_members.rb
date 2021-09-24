# frozen_string_literal: true

FactoryBot.define do
  factory :committee_member do |_cm|
    submission
    committee_role
    name { "Professor Buck Murphy" }
    sequence(:email) { |n| "abc#{n}@psu.edu" }
    sequence(:access_id) { |n| "abc#{n}" }
    is_required { true }
    is_voting { true }
    notes { '' }
    status { nil }
  end

  trait :required do
    is_required { true }
  end

  trait :optional do
    is_required { false }
  end

  trait :review_started do
    approval_started_at { DateTime.now }
  end

  # trait :advisor do
  #   committee_role_id = CommitteeRole.where(name: "#{I18n.t('current_partner.id.committee.special_role')}")
  #
  # end
  # trait :special_member do
  #   role "Special Member"
  # end
  #
end
