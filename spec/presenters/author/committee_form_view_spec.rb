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

  describe '#new_committee_label' do
    let!(:degree1) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:degree2) { FactoryBot.create :degree, degree_type: (FactoryBot.create :degree_type) }
    let!(:author) { FactoryBot.create :author }

    context 'when submission is a dissertation' do
      let!(:submission) do
        FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)],
                                       author: author, degree: degree1
      end

      it 'returns "Committee Members"' do
        view = described_class.new(submission)
        expect(view.new_committee_label).to eq('Committee Members')
      end
    end

    context 'when submission is not a dissertation' do
      let!(:submission) do
        FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)],
                                       author: author, degree: degree2
      end

      it 'returns "Add Committee Members"' do
        view = described_class.new(submission)
        expect(view.new_committee_label).to eq('Add Committee Members')
      end
    end
  end

  describe '#update_committee_label' do
    let!(:degree1) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:degree2) { FactoryBot.create :degree, degree_type: (FactoryBot.create :degree_type) }
    let!(:author) { FactoryBot.create :author }

    context 'when submission is a dissertation' do
      let!(:submission) do
        FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)],
                                       author: author, degree: degree1
      end

      it 'returns "Committee Members"' do
        view = described_class.new(submission)
        expect(view.update_committee_label).to eq('Committee Members')
      end
    end

    context 'when submission is not a dissertation' do
      let!(:submission) do
        FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)],
                                       author: author, degree: degree2
      end

      it 'returns "Update Committee Members"' do
        view = described_class.new(submission)
        expect(view.update_committee_label).to eq('Update Committee Members')
      end
    end
  end

  describe '#add_member_label' do
    let!(:degree1) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:degree2) { FactoryBot.create :degree, degree_type: (FactoryBot.create :degree_type) }
    let!(:author) { FactoryBot.create :author }

    context 'when submission is a dissertation' do
      let!(:submission) do
        FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)],
                                       author: author, degree: degree1
      end

      it 'returns "Add Special Signatory"' do
        view = described_class.new(submission)
        expect(view.add_member_label).to eq('Add Special Signatory')
      end
    end

    context 'when submission is not a dissertation' do
      let!(:submission) do
        FactoryBot.create :submission, committee_members: [FactoryBot.create(:committee_member)],
                                       author: author, degree: degree2
      end

      it 'returns "Add Committee Member"' do
        view = described_class.new(submission)
        expect(view.add_member_label).to eq('Add Committee Member')
      end
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
