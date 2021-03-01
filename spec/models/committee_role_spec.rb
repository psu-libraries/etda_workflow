# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe CommitteeRole, type: :model do
  before do
    @ordered_roles_list = CommitteeRole::ROLES[current_partner.id][DegreeType.default.slug].map { |x| x[:name] }.sort
  end

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:num_required).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:is_active).of_type(:boolean).with_options(null: false) }
  it { is_expected.to have_db_column(:code).of_type(:string) }
  it { is_expected.to have_db_column(:degree_type_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_index(:degree_type_id) }
  it { is_expected.to belong_to(:degree_type).class_name('DegreeType') }
  it { is_expected.to have_many :committee_members }

  describe "the CommitteeRole seed data" do
    context "seed committee role data for the current partner" do
      it "creates the essential committee roles collections" do
        expect(DegreeType.default.committee_roles.order('name asc').collect(&:name)).to eq(@ordered_roles_list)
      end
    end
  end

  describe 'add_lp_role' do
    it 'creates a committee role if it does not already exist' do
      bogus_name = 'bogus committee role name'
      expect(described_class.find_by_name(bogus_name.to_s)).to be_nil
      described_class.add_lp_role(bogus_name.to_s)
      expect(described_class.find_by_name(bogus_name.to_s)).not_to be_nil
    end
  end

  describe 'advisor_role' do
    it 'returns the ID of the special role for each partner' do
      role_id = described_class.advisor_role
      role = described_class.find(role_id)
      expect(role).not_to be_blank
      # expect(role).to_include ('value from locales file......')
    end
  end
end
