FactoryBot.define do
  factory :degree_type do
    sequence(:slug) { |i| "degree_type_#{i}" }
    sequence(:name) { |i| "Degree Type ##{i}" }
  end
end
