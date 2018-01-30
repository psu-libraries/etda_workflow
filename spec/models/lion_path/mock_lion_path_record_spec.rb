require 'model_spec_helper'

RSpec.describe LionPath::MockLionPathRecord, type: :model do
  first_degree_code = LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_CODE]
  first_degree_description = LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_DESC]
  it 'returns data from the static mock record' do
    expect(described_class.current_data).to be_a_kind_of(Hash)
    expect(described_class.first_degree_code).to be_a_kind_of(String)
    expect(described_class.first_degree_description).to be_a_kind_of(String)
    expect(described_class.first_degree_code).to eql(first_degree_code)
    expect(described_class.first_degree_description).to eql(first_degree_description)
  end
  it 'returns a Lion Path error response' do
    expect(described_class.error_response).to be_a_kind_of(Hash)
    expect(described_class.error_response).to eq(pe_etd_comm_fault: { emplid: "99999", err_nbr: 400, err_msg: "No valid Academic Plan " })
  end
end
