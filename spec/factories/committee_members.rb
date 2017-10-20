FactoryGirl.define do
  factory :committee_member do |_cm|
    submission
    committee_role
    name { "Professor Buck Murphy" }
    email { "buck@hotmail.com" }
    is_required { true }
  end

  trait :required do
    is_required true
  end

  trait :optional do
    is_required false
  end

  # trait :special_member do
  #   role "Special Member"
  # end
  #
end
