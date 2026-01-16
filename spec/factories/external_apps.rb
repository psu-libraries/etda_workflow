# frozen_string_literal: true

FactoryBot.define do
  factory :external_app do
    name { Faker::App.name }
  end
end
