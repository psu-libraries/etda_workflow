# frozen_string_literal: true

FactoryBot.define do
  factory :degree do
    name
    description
    is_active true
    degree_type_id { DegreeType.first.id }
  end
end
