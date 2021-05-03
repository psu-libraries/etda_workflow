require 'model_spec_helper'

RSpec.describe ExportCsv, type: :model do
  let(:author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, author: author }
  let(:committee) { FactoryBot.create_committee(submission) }
  let(:export_csv) { described_class.new('final_submission_approved', submission) }

  describe 'csv for final_submission_approved' do
    context 'columns' do
      it 'has initialized columns' do
        expect(export_csv.columns).to include('Access Level')
      end
    end

    context 'fields when initialized with one submission' do
      it 'has one submission' do
        fields = export_csv.fields(submission)
        expect(fields).not_to be(nil)
        expect(fields).to include(author.last_name)
        expect(fields).to include(author.first_name)
        expect(fields).to include(submission.title)
      end
    end

    context 'when given an invalid query type' do
      it 'returns nil' do
        export_csv = described_class.new('bogus_query', submission)
        expect(export_csv.columns).to be_nil
        expect(export_csv.fields(submission)).to be_nil
      end
    end

    context 'no submissions' do
       it 'returns nil' do
         export_csv = described_class.new('final_submission_approved', nil)
         expect(export_csv.columns).not_to be_nil
         expect(export_csv.fields(nil)).to be_nil
       end
    end
  end

  describe 'csv for custom report' do
    let(:author) { FactoryBot.create :author }
    let(:author2) {}
    let(:submission) { FactoryBot.create :submission, :released_for_publication, author: author }
    let(:committee) { create_committee(submission) }
    let(:export_csv) { described_class.new('custom_report', submission) }

    context 'columns' do
      it 'has initialized columns' do
        expect(export_csv.columns).to eq(['Last Name', 'First Name', 'Id', 'Title', 'Degree', 'Program', 'Access Level', 'Date', 'Status', 'Invention Disclosure Number'])
      end
    end

    context 'fields when initialized with one submission' do
      it 'has one submission' do
        fields = export_csv.fields(submission)
        expect(fields).not_to be(nil)
        expect(fields).to include(author.last_name)
        expect(fields).to include(author.first_name)
        expect(fields).to include(submission.title)
        expect(fields).to include(submission.degree_type.name)
        expect(fields).to include(submission.program.name)
      end
    end

    context 'when given an invalid query type' do
      it 'returns nil' do
        export_csv = described_class.new('bogus_query', submission)
        expect(export_csv.columns).to be_nil
        expect(export_csv.fields(submission)).to be_nil
      end
    end

    context 'no submissions' do
      it 'returns nil' do
        export_csv = described_class.new('custom_report', nil)
        expect(export_csv.columns).not_to be_nil
        expect(export_csv.fields(nil)).to be_nil
      end
    end
  end
end
