require 'model_spec_helper'

RSpec.describe LionPath::LpEtdPlan, type: :model do
  let(:author) { create :author }
  let(:code) { LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_CODE] }
  let(:lp_plan) { described_class.new(LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN][0]) }

  before do
    Degree.create(name: 'PHD', description: 'PHD', degree_type: DegreeType.where(slug: 'dissertation').first)
  end

  if current_partner.graduate?
    context "data#" do
      it 'returns one set of plan data with ETD values' do
        expect(lp_plan.data).to be_a_kind_of(Hash)
        expect(lp_plan.data).to include(lp_degree_code: LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN][0][LionPath::LpKeys::DEGREE_CODE])
        expect(lp_plan.etd_degree_id).to be_a_kind_of(Integer)
        expect(lp_plan.etd_program_id).to be_a_kind_of(Integer)
        expect(lp_plan.etd_defense_date).to be_a_kind_of(String)
        expect(lp_plan.etd_semester).to be_a_kind_of(String)
        expect(lp_plan.etd_year).to be_a_kind_of(String)
        expect(lp_plan.etd_program_name).to be_a_kind_of(String)
        expect(lp_plan.etd_degree_name).to be_a_kind_of(String)
      end
    end

  end
end
