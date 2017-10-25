FactoryBot.define do
  factory :submission, class: Submission do |_s|
    sequence(:title) { |n| "A Title t#{n}" }
    author
    program
    degree
    semester "Spring"
    year Time.zone.today.year
    defended_at Time.zone.tomorrow if EtdaUtilities::Partner.current.graduate?
    #    lion_path_degree_code { LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_CODE] }
  end
end
