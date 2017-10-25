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

  describe 'validates' do
    let(:submission) { FactoryBot.create(:submission) }
    let(:cm) { described_class.new }
    it 'is not valid' do
      expect(cm.valid?).to be_falsey
    end
    let(:committee_role) { FactoryBot.create(:committee_role) }
    it 'is valid' do
      cm.name = 'Mr. Committee Member'
      cm.email = 'email@psu.edu'
      cm.committee_role_id = committee_role.id
      cm.submission_id = submission.id
      cm.is_required = true
      puts cm.inspect
      puts cm.valid?.inspect
      expect(cm.valid?).to be_truthy
    end
  end
  # context 'submission_id' do
  #   it 'has a submission id' do
  #     expect(committee_member.submission_id).not_to be_nil
  #   end
  # end
  #
  # context 'role name' do
  #   before { committee_member.committee_role_id = CommitteeRole.first.id }
  #   it 'returns the role name' do
  #     expect(committee_member.role).to eq(CommitteeRole.first.name)
  #   end
  # end
  #
  # context 'advisors' do
  #   before do
  #     committee_member.committee_role_id = CommitteeRole.advisor_role
  #     committee_member.name = "I am #{EtdaUtilities::Partner.current.id}.committee.special_role"
  #     committee_member.submission_id = submission.id
  #     committee_member.save
  #   end
  #   it 'returns the Committee Members who have an Advisor Role' do
  #     advisor_member = committee_member
  #     expect(described_class.advisors(submission)).to eq([advisor_member])
  #   end
  # end
end
