# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    access_id 'admin123'
    psu_email_address 'admin@psu.edu'
    psu_idn '99999999'
    first_name "Betty"
    last_name "Partner-Admin"
    phone_number "888-193-3333"
    address_1 "123 Example Ave."
    administrator true
    site_administrator false
    updated_at { 4.days.ago }
  end

  trait :site_administration do
    site_administrator true
  end
end
