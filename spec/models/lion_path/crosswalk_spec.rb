require 'model_spec_helper'

RSpec.describe LionPath::Crosswalk, type: :model do
  if current_partner.graduate?

    context '#lp_to_etd_degree' do
      it "when given a LP degree code, returns the correct ETD degree type" do
        Degree.create(name: 'M Ed', description: 'Master Ed', degree_type: DegreeType.where(slug: 'master_thesis').first)
        Degree.create(name: 'PHD', description: 'PHD', degree_type: DegreeType.where(slug: 'dissertation').first)
        med = Degree.where(name: 'M Ed').first
        phd = Degree.where(name: 'PhD').first

        expect(described_class.new.lp_to_etd_degree('AGRIC_PHD')).to eq(phd)
        expect(described_class.new.lp_to_etd_degree('CURRINSTR_M_ED')).to eq(med)
      end
    end
    context '#semester and #year' do
      it 'formats lion path semester and year for ETD' do
        grad_date = 'SP 2017'
        selected_year = '2017'
        selected_semester = 'Spring'
        expect(described_class.grad_semester(grad_date)).to eq(selected_semester)
        expect(described_class.grad_year(grad_date)).to eq(selected_year)
      end
    end
    context '#convert_to_datetime' do
      it 'converts lion path defense date to datetime value for ETD' do
        lp_date = '2016-03-26'
        etd_date = described_class.convert_to_datetime(lp_date)
        expect(etd_date.to_date.strftime(LionPath::LpFormats::DEFENSE_DATE_FORMAT)).to eq(lp_date)
      end
    end
    context '#lp_etd_to_lp_access' do
      it 'converts the etd submission access_level to lion path access level' do
        expect(described_class.etd_to_lp_access('')).to eq('OPEN')
        expect(described_class.etd_to_lp_access('open_access')).to eq('OPEN')
        expect(described_class.etd_to_lp_access('restricted')).to eq('RSTR')
        expect(described_class.etd_to_lp_access('restricted_to_institution')).to eq('RPSU')
      end
    end
  end
end
