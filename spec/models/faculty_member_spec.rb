# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe FacultyMember, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:first_name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:last_name).of_type(:string).with_options(null: false)  }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:department).of_type(:string) }
  it { is_expected.to have_db_column(:webaccess_id).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_index(:webaccess_id) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:webaccess_id) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:committee_members) }
  end
end
