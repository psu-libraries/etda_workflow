require 'model_spec_helper'

RSpec.describe Lionpath::LionpathCommitteeRoles do
  subject(:lionpath_committee_roles) { described_class.new }

  let!(:committee_role) do
    FactoryBot.create :committee_role, degree_type: DegreeType.default,
                                       name: 'Outside Unit Member',
                                       code: 'U',
                                       lionpath_updated_at: (DateTime.now - 1.minute)
  end

  context 'when row code matches committee role and status is inactive' do
    let(:row1) do
      {
        'Type' => 'U', 'Status' => 'I', 'Description' => 'Outside Unit Member'
      }
    end

    it 'updates the existing role' do
      expect { lionpath_committee_roles.import(row1) }.to(change { committee_role.reload.lionpath_updated_at })
      expect(CommitteeRole.count).to eq 14
      committee_role.reload
      expect(committee_role.is_active).to eq false
      expect(committee_role.is_program_head).to eq false
    end
  end

  context "when no existing committee role matches the row's code" do
    let(:row2) do
      {
        'Type' => 'PRIM', 'Status' => 'A', 'Description' => 'Primary Supervisor'
      }
    end

    it 'creates a new role' do
      expect { lionpath_committee_roles.import(row2) }.to change(CommitteeRole, :count).by 1
      expect(CommitteeRole.last.name).to eq 'Primary Supervisor'
      expect(CommitteeRole.last.code).to eq 'PRIM'
      expect(CommitteeRole.last.lionpath_updated_at).to be_truthy
      expect(CommitteeRole.last.is_program_head).to eq false
    end
  end
end
