# frozen_string_literal: true

FactoryBot.define do
  factory :keyword do
    submission
    word { 'history' }
  end
end
