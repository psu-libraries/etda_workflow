FactoryBot.define do
  factory :degree do
    name
    description
    degree_type { DegreeType.first }
  end
end
