# frozen_string_literal: true

FactoryBot.define do
  factory :approval_configuration do |_ac|
    rejections_permitted { 0 }
    degree_type
  end
end
