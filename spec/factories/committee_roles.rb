FactoryBot.define do
  factory :committee_role do
    sequence(:name) { |i| "Committee Role ##{i}" }
    is_active true
    num_required 1
    degree_type
  end
end
