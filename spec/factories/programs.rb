# frozen_string_literal: true

FactoryBot.define do
  factory :program do |_p|
    name
    sequence(:code) { |n| 'CODE' + n.to_s }
  end
end
