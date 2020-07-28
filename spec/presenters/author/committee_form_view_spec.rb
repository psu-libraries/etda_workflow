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

  context '#new_committee_label' do
    author = FactoryBot.create :author
    submission = FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)], author: author
    it 'returns "Add Committee Members"' do
      view = described_class.new(submission)
      expect(view.new_committee_label).to eq('Add Committee Members')
    end
  end

  context '#link_text' do
    author = FactoryBot.create :author
    submission = FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)], author: author
    puts submission.committee_members.count.inspect
    it 'returns "update_committee_label" when updating an existing committee member' do
      view = described_class.new(submission)
      allow(view).to receive(:update?).and_return(true)
      expect(view.link_text).to eql('Update Committee Members')
    end
  end
end
