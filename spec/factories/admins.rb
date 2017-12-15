FactoryBot.define do
  factory :admin, class: Admin do |_p|
    sequence :access_id, 1000 do |n|
      "ADM#{n}"
    end
    sequence :psu_email_address, 1000 do |n|
      "ADM#{n}@psu.edu"
    end
    # rubocop:disable Style/NumericLiterals
    sequence :psu_idn, 900000000 do |n|
      "#{n}".to_s
    end
    # rubocop:enable Style/NumericLiterals

    first_name "Betty"
    last_name "Partner-Admin"
    phone_number "888-193-3333"
    address_1 "123 Example Ave."
    administrator true
    site_administrator false
    updated_at 4.days.ago
  end

  trait :site_administrator do
    site_administrator true
  end
end
