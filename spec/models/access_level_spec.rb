# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe AccessLevel do
  let(:open_access_view_struct) { { type: 'open_access', label: 'Open Access', description: EtdaUtilities::AccessLevel.partner_access_levels['access_level']['open_access_attr']['description_html'] } }
  let(:restricted_view_struct) { { type: 'restricted', label: 'Restricted', description: EtdaUtilities::AccessLevel.partner_access_levels['access_level']['restricted_attr']['description_html'] } }
  let(:restricted_to_institution_view_struct) { { type: 'restricted_to_institution', label: 'Restricted (Penn State Only)', description: EtdaUtilities::AccessLevel.partner_access_levels['access_level']['restricted_to_institution_attr']['description_html'] } }

  context '#ACCESS_LEVEL_KEYS' do
    it 'constant containing all access levels' do
      expect(described_class::ACCESS_LEVEL_KEYS).to match_array(['open_access', 'restricted_to_institution', 'restricted'])
      expect(described_class::ACCESS_LEVEL_KEYS).to include('open_access')
      expect(described_class::ACCESS_LEVEL_KEYS).to include('restricted')
      expect(described_class::ACCESS_LEVEL_KEYS).to include('restricted_to_institution')
      expect(described_class::ACCESS_LEVEL_KEYS.length).to eq(3)
    end
  end
  context '#paper_access_level_keys' do
    it '#paper_access_level_keys returns an array of access_levels' do
      expect(described_class::ACCESS_LEVEL_KEYS).to match_array(described_class.paper_access_level_keys)
    end
  end
  context '#partner_access_level' do
    it 'returns access level information from a yml file' do
      yml_level = described_class.partner_access_levels['access_level']
      expect(yml_level['open_access']).to include('Open Access')
      expect(yml_level['restricted_to_institution']).to include('Restricted (Penn State Only)')
      expect(yml_level['restricted']).to include('Restricted')
    end
  end

  context '#valid_levels' do
    it 'returns access_levels including no level' do
      expect(described_class.valid_levels).to match_array(described_class.paper_access_level_keys + [''])
      expect(described_class.valid_levels).not_to match_array(described_class.paper_access_level_keys)
    end
  end

  describe '#paper_access_levels' do
    it "returns a hash usable in a view" do
      expect(described_class.paper_access_levels).to include(open_access_view_struct)
      expect(described_class.paper_access_levels).to include(restricted_view_struct)
      expect(described_class.paper_access_levels).to include(restricted_to_institution_view_struct)
    end
  end

  describe 'ordering' do
    it "levels should evaluate int he correct order" do
      expect(described_class.OPEN_ACCESS.to_i < described_class.RESTRICTED.to_i).to be_truthy
      expect(described_class.OPEN_ACCESS.to_i < described_class.RESTRICTED_TO_INSTITUTION.to_i).to be_truthy
      expect(described_class.RESTRICTED_TO_INSTITUTION.to_i < described_class.RESTRICTED.to_i).to be_truthy
    end
  end
end
