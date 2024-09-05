FactoryBot.define do
  factory :federal_funding_details do
    training_support_funding { false }
    training_support_acknowledged { false }
    other_funding { false }
    other_funding_acknowledged { false }
  end
end
