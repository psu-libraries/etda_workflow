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

  context '#committee_form_partial' do
    author = FactoryBot.create :author
    submission = FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)], author: author
    it 'returns the standard_committee_form when no lion path record is available' do
      view = described_class.new(submission)
      expect(view.committee_form_partial).to eq('standard_committee_form')
    end
    it 'returns lionpath_committee_form when there is a lion path record' do
      allow_any_instance_of(Submission).to receive(:using_lionpath?).and_return(true)
      view = described_class.new(submission)
      expect(view.committee_form_partial).to eql('lionpath_committee_form')
    end
  end

  context '#new_committee_label' do
    author = FactoryBot.create :author
    submission = FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)], author: author
    it 'returns "Add Committee Members" when no lion path record is available' do
      view = described_class.new(submission)
      expect(view.new_committee_label).to eq('Add Committee Members')
    end
    it 'returns "Verify Committee" when there is a lion path record' do
      allow_any_instance_of(Submission).to receive(:using_lionpath?).and_return(true)
      view = described_class.new(submission)
      expect(view.new_committee_label).to eql('Verify Committee')
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
    it 'returns "Refresh Committee" when committee existing using Lion Path' do
      view = described_class.new(submission)
      allow(view).to receive(:update?).and_return(true)
      allow(submission).to receive(:using_lionpath?).and_return(true)
      expect(view.link_text).to eql('Refresh Committee')
    end
  end
end
