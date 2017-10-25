FactoryBot.define do
  factory :invention_disclosure do |_invention_disclosure|
    submission_id { submission }
    id_number { "#{Time.zone.now.year}-1234" }
  end
end
