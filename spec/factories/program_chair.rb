FactoryBot.define do
  factory :program_chair do
    program
    sequence(:access_id) { |n| 'abc' + n.to_s }
    sequence(:first_name) { |n| 'Test' + n.to_s }
    last_name { 'Tester' }
    campus { 'UP' }
    phone { 18141234567 }
    email { access_id + '@psu.edu' }
    role { "Department Head" }
  end
end
