# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'
require 'support/request_spec_helper'

RSpec.describe CommitteeMember, type: :model do
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:committee_role_id).of_type(:integer) }
  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:email).of_type(:string) }
  it { is_expected.to have_db_column(:is_required).of_type(:boolean) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_index(:submission_id) }
  it { is_expected.to have_db_index(:committee_role_id) }
  it { is_expected.to belong_to(:submission).class_name('Submission') }
  it { is_expected.to belong_to(:committee_role).class_name('CommitteeRole') }

  let(:committee_member) { described_class.new }
  describe 'committee_member' do
    context 'member is required' do
      it 'is true' do
        expect(committee_member.is_required).to be(true)
      end
    end

    context 'committee_role_id is present' do
      it 'has a committee role id' do
        expect(committee_member.committee_role_id).not_to be 0
      end
    end
    context 'committee_member name' do
      it 'is not blank' do
        expect(committee_member.name).not_to be_blank
      end
    end

    context 'committee member email' do
      it 'has a valid email address' do
        expect(committee_member.email).not_to be_blank
      end
    end

    context 'submission_id' do
      it 'has a submission id' do
        expect(committee_member.submission_id).not_to be_nil
      end
    end

    context 'role name' do
      before { committee_member.committee_role_id = CommitteeRole.first.id }
      it 'returns the role name' do
        expect(committee_member.role).to eq(CommitteeRole.first.name)
      end
    end

    context 'advisors' do
      before do
        committee_member.committee_role_id = CommitteeRole.advisor_role
        committee_member.name = "I am #{EtdaUtilities::Partner.current.id}.committee.special_role"
        committee_member.submission_id = submission.id
        committee_member.save
      end
      it 'returns the Committee Members who have an Advisor Role' do
        advisor_member = committee_member
        expect(described_class.advisors(submission)).to eq([advisor_member])
      end
    end
  end
end
