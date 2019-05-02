require 'presenters/presenters_spec_helper'
RSpec.describe Author::CommitteeMemberView do
  let(:view) { described_class.new(member) }
  let(:member) { FactoryBot.create :committee_member, committee_role: role }
  let(:role) { FactoryBot.create(:committee_role, name: 'My Role') }
  let(:head_role) { FactoryBot.create(:committee_role, name: 'Head/Chair of Graduate Program') }

  describe '#role' do
    subject { view.role }

    it { is_expected.to eq('My Role') }
  end

  describe '#possible_roles' do
    subject { view.possible_roles }

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
end
