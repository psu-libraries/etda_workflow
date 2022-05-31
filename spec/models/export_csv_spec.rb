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
        expect(export_csv.columns).to eq([
                                           'Submission ID',
                                           'Last Name',
                                           'First Name',
                                           'PSU ID',
                                           'Title',
                                           'Degree',
                                           'Program',
                                           'Access Level',
                                           'Status',
                                           'Date',
                                           'Federal Funding?',
                                           'Advisor Name',
                                           'PSU Email',
                                           'Alternate Email',
                                           'Academic Program',
                                           'Degree Checkout Status',
                                           'Admin Notes'
                                         ])
      end
    end

    context 'fields when initialized with one submission' do
      it 'has one submission' do
        fields = export_csv.fields(submission)
        expect(fields).not_to be(nil)

        expect(fields).to eq([
                               submission.id,
                               submission.author.last_name,
                               submission.author.first_name,
                               submission.author.psu_id,
                               submission.cleaned_title,
                               submission.degree_type.name,
                               submission.program_name,
                               submission.current_access_level.label,
                               submission.admin_status,
                               submission.preferred_semester_and_year,
                               submission.federal_funding_display,
                               CommitteeMember.advisor_name(submission),
                               submission.author.psu_email_address,
                               submission.author.alternate_email_address,
                               submission.academic_program,
                               submission.degree_checkout_status,
                               submission.admin_notes
                             ])
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
