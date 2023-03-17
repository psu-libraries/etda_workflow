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

    it 'Validates the uniqueness of webaccess id' do
      faculty_member = create(:faculty_member)
      expect { create(:faculty_member, webaccess_id: faculty_member.webaccess_id) }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Webaccess has already been taken')
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:committee_members) }
  end
end
