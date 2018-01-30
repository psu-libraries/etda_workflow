# frozen_string_literal: true

require 'model_spec_helper'

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
    let(:committee_role) { FactoryBot.create(:committee_role) }

    it 'is not valid' do
      expect(cm).not_to be_valid
    end

    it 'is valid' do
      cm.name = 'Mr. Committee Member'
      cm.email = 'email@psu.edu'
      cm.committee_role_id = committee_role.id
      cm.submission_id = submission.id
      cm.is_required = true
      expect(cm).to be_valid
    end
  end
  # context 'submission_id' do
  #   it 'has a submission id' do
  #     expect(committee_member.submission_id).not_to be_nil
  #   end
  # end
  #
  context 'role name' do
    it 'returns the role name' do
      committee_member = described_class.new(committee_role_id: CommitteeRole.first.id)
      expect(committee_member.role).to eq(CommitteeRole.first.name)
    end
  end

  context 'advisors' do
    xit 'returns the Committee Members who have an Advisor Role' do
      submission = FactoryBot.create(:submission)
      committee_member = described_class.create(committee_role_id: CommitteeRole.advisor_role, name: "I am #{I18n.t('current_partner.id.committee.special_role')}", submission_id: submission.id)
      committee_member.save
      advisor_member = committee_member
      expect(described_class.advisors(submission)).to eq([advisor_member])

      # expect(described_class.advisor_name(submission)).to eq(submission.committee_members.where(committee_role_id: CommitteeRole.advisor_role))
    end
  end
end
