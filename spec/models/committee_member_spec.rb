# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe CommitteeMember, type: :model do
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:committee_role_id).of_type(:integer) }
  it { is_expected.to have_db_column(:approver_id).of_type(:integer) }
  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:email).of_type(:string) }
  it { is_expected.to have_db_column(:is_required).of_type(:boolean) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:access_id).of_type(:string) }
  it { is_expected.to have_db_column(:approval_started_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:approved_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:rejected_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:reset_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:status).of_type(:string) }
  it { is_expected.to have_db_column(:last_notified_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:last_notified_type).of_type(:string) }
  it { is_expected.to have_db_column(:notes).of_type(:text) }
  it { is_expected.to have_db_index(:submission_id) }
  it { is_expected.to have_db_index(:committee_role_id) }
  it { is_expected.to have_db_column(:last_reminder_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:is_voting).of_type(:boolean) }
  it { is_expected.to have_db_column(:lionpath_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:external_to_psu_id).of_type(:string) }
  it { is_expected.to have_db_index(:approver_id) }
  it { is_expected.to belong_to(:submission).class_name('Submission') }
  it { is_expected.to belong_to(:committee_role).class_name('CommitteeRole') }
  it { is_expected.to belong_to(:approver).class_name('Approver').optional }
  it { is_expected.to have_one(:committee_member_token).class_name('CommitteeMemberToken') }

  describe 'defaults' do
    let(:cm) { described_class.new }

    it 'has is_voting defaulted to false' do
      expect(cm.is_voting).to eq false
    end

    it 'has status defaulted to ""' do
      expect(cm.status).to eq ""
    end
  end

  describe 'validates' do
    let(:submission) { FactoryBot.create(:submission) }
    let(:cm) { described_class.new }
    let(:committee_role) { FactoryBot.create(:committee_role) }

    before do
      cm.committee_role_id = committee_role.id
    end

    it 'is not valid' do
      expect(cm).not_to be_valid
    end

    it 'is valid' do
      cm.name = 'Professor Buck Murphy'
      cm.email = 'buck@hotmail.com'
      cm.submission_id = submission.id
      cm.is_required = true
      expect(cm).to be_valid
    end
  end

  describe 'status' do
    let(:submission) { FactoryBot.create(:submission) }
    let(:cm) { described_class.new }
    let(:cm_dup) { described_class.new }
    let(:committee_role) { FactoryBot.create(:committee_role) }

    before do
      cm.committee_role_id = committee_role.id
      cm_dup.committee_role_id = committee_role.id
      submission.committee_members << [cm, cm_dup]
    end

    context 'when status is nil' do
      before do
        cm.status = nil
      end

      it 'updates status column' do
        expect(cm.status).to be_blank
      end
      it 'updates timestamps' do
        expect(cm.approved_at).to be_nil
        expect(cm.rejected_at).to be_nil
      end
    end

    context 'when status is changed to approved' do
      before do
        cm.status = 'approved'
      end

      it 'updates status column' do
        expect(cm.status).to eq("approved")
      end
      it 'updates timestamps' do
        expect(cm.approved_at).to be_truthy
        expect(cm.rejected_at).to be_nil
      end
    end

    context 'when status is changed to rejected' do
      before do
        cm.status = 'rejected'
      end

      it 'updates status column' do
        expect(cm.status).to eq("rejected")
      end
      it 'updates timestamps' do
        expect(cm.approved_at).to be_nil
        expect(cm.rejected_at).to be_truthy
      end
    end

    context 'when status is changed to pending' do
      before do
        cm.status = 'pending'
      end

      it 'updates status column' do
        expect(cm.status).to eq("pending")
      end
      it 'updates timestamps' do
        expect(cm.approved_at).to be_nil
        expect(cm.rejected_at).to be_nil
      end
    end
  end

  describe 'email' do
    let(:cm) { described_class.new }
    let(:committee_role) { FactoryBot.create :committee_role }

    before do
      cm.committee_role_id = committee_role.id
    end

    context 'when email is a psu email' do
      it 'updates access_id' do
        cm.update email: 'test123@psu.edu'
        expect(cm.access_id).to eq 'test123'
      end
    end

    context 'when nil is returned' do
      it "doesn't update access_id" do
        cm.access_id = 'test123'
        allow_any_instance_of(LdapUniversityDirectory).to receive(:retrieve_committee_access_id).and_return(nil)
        cm.update email: 'test123@psu.edu'
        expect(cm.access_id).to eq 'test123'
      end
    end

    context 'when trailing and leading whitespace' do
      it 'strips whitespace' do
        cm.update email: '       test123@psu.edu       '
        expect(cm.email).to eq 'test123@psu.edu'
        expect(cm.access_id).to eq 'test123'
      end
    end
  end

  describe 'update_last_reminder_at' do
    let(:cm) { described_class.new }

    it 'updates last_reminder_at with current DateTime' do
      time_now = DateTime.now
      cm.update_last_reminder_at(time_now)
      expect(cm.last_reminder_at.strftime("%F;%H:%M")).to eq(time_now.to_time.round.strftime("%F;%H:%M"))
    end
  end

  describe 'reminder_email_authorized?' do
    let(:cm) { described_class.new }

    context 'when last_reminder_at is nil' do
      it 'returns true' do
        expect(cm.reminder_email_authorized?).to eq(true)
      end
    end

    context 'when last_reminder_at is within the past 24 hours' do
      it 'returns false' do
        time_now = DateTime.now
        cm.last_reminder_at = time_now - 1.hour

        expect(cm.reminder_email_authorized?).to eq(false)
      end
    end

    context 'when last_reminder_at is not within the past 24 hours' do
      it 'returns true' do
        time_now = DateTime.now
        cm.last_reminder_at = time_now - 25.hours

        expect(cm.reminder_email_authorized?).to eq(true)
      end
    end
  end

  context 'it has a role name' do
    it 'returns the role name' do
      committee_member = described_class.new(committee_role_id: CommitteeRole.first.id)
      expect(committee_member.committee_role.name).to eq(CommitteeRole.first.name)
    end
  end

  context 'advisors' do
    if current_partner.graduate?
      it 'returns the Committee Members who have an Advisor Role' do
        submission = FactoryBot.create(:submission)
        committee_member = described_class.create(committee_role_id: CommitteeRole.advisor_role, name: "I am " + I18n.t("#{current_partner.id}.committee.special_role"), email: 'advisor@psu.edu', submission_id: submission.id)
        committee_member.save
        advisor_member = committee_member
        expect(described_class.advisors(submission)).to eq([advisor_member])
      end
    end
  end

  context 'advisor' do
    if current_partner.graduate?
      it 'returns the Committee Member name of first advisor' do
        submission = FactoryBot.create(:submission)
        committee_member = described_class.create(committee_role_id: CommitteeRole.advisor_role, name: "I am " + I18n.t("#{current_partner.id}.committee.special_role"), email: 'advisor@psu.edu', submission_id: submission.id)
        committee_member.save
        advisor_member = committee_member.name
        expect(described_class.advisor_name(submission)).to eq(advisor_member)
      end
    end
  end

  context 'committee_role_id' do
    it 'creates a committee_member_token if special committee member' do
      submission = FactoryBot.create(:submission)
      committee_role = FactoryBot.create(:committee_role, name: 'Committee Member')
      committee_member1 = FactoryBot.create(:committee_member, committee_role_id: committee_role.id, name: "Special", email: 'person@gmail.com', submission_id: submission.id)
      committee_member2 = FactoryBot.create(:committee_member, committee_role_id: CommitteeRole.advisor_role, name: "Not Special", email: 'advisor@psu.edu', submission_id: submission.id)
      expect(described_class.find(committee_member1.id).committee_member_token).not_to be_nil
      expect(described_class.find(committee_member2.id).committee_member_token).to be_nil
    end
  end

  context 'email validation' do
    let(:submission) { FactoryBot.create(:submission) }
    let(:cm) { described_class.new }
    let(:committee_role) { FactoryBot.create(:committee_role) }

    before do
      cm.name = 'Professor Buck Murphy'
      cm.committee_role_id = committee_role.id
      cm.submission_id = submission.id
      cm.is_required = false
    end

    it 'accepts email' do
      cm.email = 'email@psu.edu'
      expect(cm).to be_valid
      cm.email = 'email@health.sdu.dk'
      expect(cm).to be_valid
      cm.email = 'jamesbrown@funky.funktown'
      expect(cm).to be_valid
    end

    it 'rejects email' do
      cm.email = 'emailpsu.edu'
      expect(cm).not_to be_valid
      cm.email = 'email@psuedu'
      expect(cm).not_to be_valid
      cm.email = 'email@ps u.edu'
      expect(cm).not_to be_valid
    end
  end

  describe 'one program head/chair validation' do
    let(:submission) { FactoryBot.create(:submission) }
    let(:cm1) { described_class.new }
    let(:cm2) { described_class.new }
    let(:committee_role) { FactoryBot.create(:committee_role, name: 'Program Head/Chair') }

    before do
      cm1.email = 'email@psu.edu'
      cm2.email = 'email@psu.edu'
      cm1.name = 'Test'
      cm2.name = 'Test'
    end

    it 'updates existing head/chair' do
      cm1.committee_role = committee_role
      submission.committee_members << cm1
      submission.reload
      cm1.name = 'Test User'
      expect(cm1).to be_valid
    end

    it 'allows new head/chair if none exists' do
      cm1.committee_role = committee_role
      submission.committee_members << cm1
      expect(cm1).to be_valid
    end

    it 'does not allow new head/chair if one exists' do
      cm1.committee_role = committee_role
      submission.committee_members << cm1
      submission.reload
      cm2.committee_role = committee_role
      submission.committee_members << cm2
      expect(cm2).not_to be_valid
    end

    it 'does not allow two new head/chairs' do
      cm1.committee_role = committee_role
      submission.committee_members << cm1
      cm2.committee_role = committee_role
      submission.committee_members << cm2
      expect(cm1).not_to be_valid
      expect(cm2).not_to be_valid
    end

    it 'committee role and submission must be present' do
      submission.committee_members << cm1
      cm2.committee_role = committee_role
      expect(cm1).not_to be_valid
      expect(cm2).not_to be_valid
      submission.committee_members << cm2
      expect(cm2).to be_valid
    end
  end

  describe 'name' do
    let(:cm) { described_class.new }

    context 'when trailing and leading whitespace' do
      it 'strips whitespace' do
        cm.update_attribute :name, '     Test Tester      '
        expect(cm.name).to eq 'Test Tester'
      end
    end
  end
end
