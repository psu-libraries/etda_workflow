FactoryBot.define do
  factory :program_chair do
    program
    sequence(:access_id) { |n| 'abc' + n.to_s }
    first_name { 'Test' }
    last_name { 'Tester' }
    campus { 'UP' }
    phone { 18141234567 }
    email { access_id + '@psu.edu' }
  end
end
