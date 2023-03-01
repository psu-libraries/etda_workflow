FactoryBot.define do
  factory :faculty_member do
    first_name { "Testname" }
    last_name { "Testlastname" }
    department { "Testdepartment" }
    webaccess_id { 'abc123' }
  end
end
