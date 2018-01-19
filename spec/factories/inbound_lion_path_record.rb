FactoryBot.define do
  factory :inbound_lion_path_record, class: InboundLionPathRecord do
    current_data { LionPath::MockLionPathRecord.current_data }
    lion_path_degree_code { LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_CODE] }
  end
end
