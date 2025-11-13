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

    context 'When deleting faculty member associated with committee member' do
      it 'nullifies committee members' do
        test_faculty = create :faculty_member
        test_committee = create :committee_member, faculty_member_id: test_faculty.id
        expect(test_committee.faculty_member_id).to eq(test_faculty.id)
        test_faculty.destroy
        expect(test_committee.reload.faculty_member_id).to be_nil
      end
    end
  end
end
