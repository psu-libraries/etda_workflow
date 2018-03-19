# frozen_string_literal: true

FactoryBot.define do
  factory :degree do
    name
    description
    is_active true
    degree_type { DegreeType.first }
  end
end
