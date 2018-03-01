require 'presenters/presenters_spec_helper'
RSpec.describe Author::CommitteeFormView do
  let(:view) { described_class.new(submission) }

  context "submission with no existing committee" do
    let(:submission) { FactoryBot.create :submission }

    describe '#update?' do
      subject { view.update? }

      it { is_expected.to be_falsey }
    end

    describe '#form_title' do
      subject { view.form_title }

      it { is_expected.to eq(view.new_committee_label) }
    end
  end

  context "submission with an existing committee" do
    let(:submission) { FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)] }

    describe '#update?' do
      subject { view.update? }

      it { is_expected.to be_truthy }
    end

    describe '#form_title' do
      subject { view.form_title }

      it { is_expected.to eq(view.update_committee_label) }
    end
  end
end
