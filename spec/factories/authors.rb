# frozen_string_literal: true

FactoryBot.define do
  factory :author, class: Author do |_p|
    sequence :access_id, 1000 do |n|
      "XYZ#{n}"
    end
    sequence :psu_email_address, 1000 do |n|
      "XYZ#{n}@psu.edu"
    end

    sequence :alternate_email_address, 1000 do |n|
      "ALT#{n}@company.com"
    end

    sequence :psu_idn, 900000000 do |n|
      n.to_s.to_s
    end

    sequence :legacy_id, 100 do |n|
      n.to_s.to_s
    end

    first_name { "Joseph" }
    middle_name { "Quicny" }
    last_name { Faker::Name.unique.name }
    phone_number { "123-456-7890" }
    is_alternate_email_public { current_partner.graduate? ? true : false }
    address_1 { "123 Example Ave." }
    address_2 { "Apt. 8H" }
    city { "State College" }
    state { "PA" }
    zip { "16801" }
    updated_at { 4.days.ago }
    admin_edited_at { nil }
    # inbound_lion_path_record { FactoryBot.create(:inbound_lion_path_record }
  end

  trait :author_from_ldap do
    alternate_email_address { "" }
    to_create { |instance| instance.save(validate: false) }
  end

  trait :confidential_hold do
    confidential_hold { true }
    confidential_hold_set_at { Time.zone.yesterday }
  end

  trait :no_lionpath_record do
    inbound_lion_path_record { nil }
  end
end
