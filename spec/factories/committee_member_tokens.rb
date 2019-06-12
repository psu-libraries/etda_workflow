FactoryBot.define do
  factory :committee_member_token do
    committee_member
    authentication_token { rand(36**8).to_s(36) }
    token_created_on { Date.today }
  end
end
