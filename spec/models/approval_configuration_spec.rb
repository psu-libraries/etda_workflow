# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe ApprovalConfiguration, type: :model do
  let(:default_degree_type_approval_configuration) { ApprovalConfiguration::CONFIGURATION[current_partner.id][DegreeType.default.slug] }

  it { is_expected.to have_db_column(:degree_type_id).of_type(:integer) }
  it { is_expected.to have_db_column(:approval_deadline_on).of_type(:date) }
  it { is_expected.to have_db_column(:email_admins).of_type(:boolean) }
  it { is_expected.to have_db_column(:email_authors).of_type(:boolean) }
  it { is_expected.to have_db_column(:use_percentage).of_type(:boolean) }
  it { is_expected.to have_db_column(:configuration_threshold).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

  it { is_expected.to have_db_index(:degree_type_id) }

  it { is_expected.to validate_presence_of :degree_type_id }

  it { is_expected.to belong_to :degree_type }

  describe "the ApprovalConfiguration seed data" do
    context "seed approval configuration data for the current partner" do
      it "creates the essential approval configurations collections" do
        expect(DegreeType.default.approval_configuration).to eq(@default_degree_type_approval_configuration)
      end
    end
  end

  describe 'validates' do
    let(:degree_type) { FactoryBot.create(:degree_type) }
    let(:ac) { described_class.new }

    it 'is not valid' do
      expect(ac).not_to be_valid
    end

    it 'is valid' do
      ac.approval_deadline_on = Date.today
      ac.configuration_threshold = 2
      ac.degree_type_id = degree_type.id
      expect(ac).to be_valid
    end
  end
end
