require 'model_spec_helper'

RSpec.describe Lionpath::LionpathCommitteeRoles do
  let!(:committee_role) { FactoryBot.create :committee_role, code: 'ABCD' }
  let(:lionpath_committee_roles) { described_class.new('spec/fixtures/lionpath_committee_roles.csv') }

  describe '#import' do
    it 'creates new committee roles and updates existing roles' do
      expect { lionpath_committee_roles.import }.to change(CommitteeRole, :count).by 2
      expect(CommitteeRole.find(committee_role.id).name).to eq 'Dissertation Advisor'
      expect(CommitteeRole.last.is_active).to eq false
    end
  end
end
