require 'presenters/presenters_spec_helper'
RSpec.describe Author::CommitteeMemberView do
  let(:view) { described_class.new(member) }
  let(:member) { FactoryBot.create :committee_member, committee_role: role }
  let(:role) { FactoryBot.create(:committee_role, name: 'My Role') }
  let(:head_role) { FactoryBot.create(:committee_role, name: 'Program Head/Chair', is_program_head: true) }

  describe '#role' do
    subject { view.role }

    it { is_expected.to eq('My Role') }
  end

  describe '#author_possible_roles' do
    subject { view.author_possible_roles }

    it { is_expected.to eq([role]) }
  end

  describe '#admin_possible_roles' do
    subject { view.admin_possible_roles }

    it { is_expected.to eq([role]) }
  end

  describe '#head_of_program?' do
    context 'when head of program' do
      subject { view.head_of_program? }

      let(:member) { FactoryBot.create :committee_member, :required, committee_role: head_role }

      it { is_expected.to be_truthy }
    end

    context 'when not head of program' do
      subject { view.head_of_program? }

      let(:member) { FactoryBot.create :committee_member, :required, committee_role: role }

      it { is_expected.to be_falsey }
    end
  end

  context "required member" do
    let(:member) { FactoryBot.create :committee_member, :required, committee_role: role }

    describe '#required?' do
      subject { view.required? }

      it { is_expected.to be_truthy }
    end

    describe '#name_label' do
      subject { view.name_label }

      it { is_expected.to eq('My Role Name') }
    end

    describe '#email_label' do
      subject { view.email_label }

      it { is_expected.to eq('My Role Email') }
    end
  end

  context "not required member" do
    let(:member) { FactoryBot.create :committee_member, :optional, committee_role: role }

    describe '#required?' do
      subject { view.required? }

      it { is_expected.to be_falsey }
    end

    describe '#name_label' do
      subject { view.name_label }

      it { is_expected.to eq('Name') }
    end

    describe '#email_label' do
      subject { view.email_label }

      it { is_expected.to eq('Email') }
    end
  end

  describe "#program_chair_collection" do
    let!(:program) { FactoryBot.create :program }
    let!(:submission) { FactoryBot.create :submission, campus: 'UP', program: program }
    let!(:program_chair1) do
      FactoryBot.create :program_chair, campus: 'UP', role: 'Professor in Charge', program: program
    end
    let!(:program_chair2) { FactoryBot.create :program_chair, campus: 'UP', program: program }
    let!(:program_chair3) { FactoryBot.create :program_chair, campus: 'HY', program: program }

    it 'returns the collection of program chairs for a submissions program' do
      submission.committee_members << member
      submission.reload
      expect(view.program_chair_collection).to eq [["Test Tester (Professor in Charge)",
                                                    "Test Tester",
                                                    { member_email: program_chair1.email }],
                                                   ["Test Tester (Department Head)",
                                                    "Test Tester",
                                                    { member_email: program_chair2.email }]]
    end
  end
end
