require 'model_spec_helper'

RSpec.describe ExportReport, type: :model do
  let(:author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, author: }
  let(:committee) { FactoryBot.create_committee(submission) }
  let(:export_report) { described_class.new('final_submission_approved', submission) }

  describe 'csv for final_submission_approved' do
    context 'columns' do
      it 'has initialized columns' do
        expect(export_report.columns).to include('Access Level')
      end
    end

    context 'fields when initialized with one submission' do
      it 'has one submission' do
        fields = export_report.fields(submission)
        expect(fields).not_to be(nil)
        expect(fields).to include(author.last_name)
        expect(fields).to include(author.first_name)
        expect(fields).to include(submission.title)
      end
    end

    context 'when given an invalid query type' do
      it 'returns nil' do
        export_report = described_class.new('bogus_query', submission)
        expect(export_report.columns).to be_nil
        expect(export_report.fields(submission)).to be_nil
      end
    end

    context 'no submissions' do
      it 'returns nil' do
        export_report = described_class.new('final_submission_approved', nil)
        expect(export_report.columns).not_to be_nil
        expect(export_report.fields(nil)).to be_nil
      end
    end
  end

  describe 'csv for custom report' do
    let(:author) { FactoryBot.create :author }
    let(:author2) {}
    let(:submission) { FactoryBot.create :submission, :released_for_publication, author: }
    let(:committee) { create_committee(submission) }
    let(:export_report) { described_class.new('custom_report', submission) }

    context 'columns' do
      it 'has initialized columns', honors: true, graduate: true do
        array = [
          'Submission ID',
          'Last Name',
          'First Name',
          'PSU ID',
          'Title',
          'Degree',
          'Program',
          'Access Level',
          'Status',
          'Graduation Date',
          'Federal Funding?',
          'Advisor Name',
          'PSU Email',
          'Alternate Email',
          'Academic Program',
          'Degree Checkout Status',
          'Admin Notes'
        ]
        array.insert(12, "Thesis Supervisor Name") if current_partner.honors?
        expect(export_report.columns).to eq(array)
      end
    end

    context 'fields when initialized with one submission' do
      it 'has one submission', honors: true, graduate: true do
        fields = export_report.fields(submission)
        expect(fields).not_to be(nil)
        array = [
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
        ]
        array.insert(12, CommitteeMember.thesis_supervisor_name(submission)) if current_partner.honors?
        expect(fields).to eq(array)
      end
    end

    context 'when given an invalid query type' do
      it 'returns nil' do
        export_report = described_class.new('bogus_query', submission)
        expect(export_report.columns).to be_nil
        expect(export_report.fields(submission)).to be_nil
      end
    end

    context 'no submissions' do
      it 'returns nil' do
        export_report = described_class.new('custom_report', nil)
        expect(export_report.columns).not_to be_nil
        expect(export_report.fields(nil)).to be_nil
      end
    end
  end

  # describe 'graduate_data_report' do
  #   let(:author) { FactoryBot.create :author }
  #   let(:submission) { FactoryBot.create :submission, :released_for_publication, author: }
  #   let(:export_report) { described_class.new('graduate_data_report', submission) }
  #   let(:cm1) { FactoryBot.create :committee_member, committee_role: com_role1 }
  #   let(:com_role1) { CommitteeRole.where(name: "Program Head/Chair").sample }
  #   let(:cm2) { FactoryBot.create :committee_member, committee_role: com_role2 }
  #   let(:com_role2) { CommitteeRole.where(name: "Thesis Advisor/Co-Advisor").sample }
  #   let(:expected_formatted_committee) { [{ email: cm1.email.to_s, name: cm1.name.to_s, role: cm1.committee_role.name.to_s }, { email: cm2.email.to_s, name: cm2.name.to_s, role: cm2.committee_role.name.to_s }] }

  #   before do
  #     submission.committee_members << [cm1, cm2]
  #   end

  #   context 'columns' do
  #     it 'has initialized columns' do
  #       expect(export_report.columns).to include('access_id')
  #       expect(export_report.columns).to include('alternate_email_address')
  #       expect(export_report.columns).to include('committee_members')
  #     end
  #   end

  #   context 'fields when initialized with one submission' do
  #     it 'has one submission' do
  #       fields = export_report.fields(submission)
  #       expect(fields).not_to be(nil)
  #       expect(fields[:access_id]).to eq(author.access_id)
  #       expect(fields[:alternate_email_address]).to eq(author.alternate_email_address)

  #       expect(fields[:committee_members]).to eq(expected_formatted_committee)
  #     end
  #   end
  # end
end
