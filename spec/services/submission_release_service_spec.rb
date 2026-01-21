require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe SubmissionReleaseService do
  let(:service) { described_class.new }

  before do
    stub_request(:post, "https://etda.localhost:3000/solr/update?wt=json")
  end

  describe '#publish' do
    context "when release_type is 'Release selected for publication'" do
      let(:release_type) { 'Release selected for publication' }

      context "when submission's access level is open_access" do
        let(:submission) do
          FactoryBot.create :submission, :waiting_for_publication_release, access_level: 'open_access'
        end

        it "changes the submission's status to 'released for publication" do
          service.publish([submission.id], DateTime.now, release_type)
          submission.reload
          expect(submission.status).to eq 'released for publication'
        end
      end

      context "when submission's access_level is restricted_to_institution" do
        let(:submission) do
          FactoryBot.create :submission, :waiting_for_publication_release, access_level: 'restricted_to_institution'
        end

        it "changes the submission's status to 'released for publication metadata only'" do
          service.publish([submission.id], DateTime.now, release_type)
          submission.reload
          expect(submission.status).to eq 'released for publication metadata only'
        end
      end

      context "when submission's access_level is restricted" do
        let(:submission) do
          FactoryBot.create :submission, :waiting_for_publication_release, access_level: 'restricted_to_institution'
        end

        it "changes the submission's status to 'released for publication metadata only" do
          service.publish([submission.id], DateTime.now, release_type)
          submission.reload
          expect(submission.status).to eq 'released for publication metadata only'
        end
      end
    end

    context "when release_type is 'Released as Open Access'" do
      let(:release_type) { 'Release as Open Access' }
      let(:submission) do
        FactoryBot.create :submission, :final_is_restricted_to_institution
      end

      it "changes the access_level to open_access and status to 'released for publication'" do
        service.publish([submission.id], DateTime.now, release_type)
        submission.reload
        expect(submission.status).to eq 'released for publication'
        expect(submission.access_level).to eq 'open_access'
      end
    end

    it 'indexes submission' do
      release_type = 'Release as Open Access'
      submission = FactoryBot.create :submission, :final_is_restricted_to_institution
      expect_any_instance_of(SolrDataImportService).to receive(:index_submission)
      service.publish([submission.id], DateTime.now, release_type)
    end
  end

  describe '#unpublish' do
    it 'delegates to #release_files and returns its result' do
      original_final_files = [[1, '/some/path/file.pdf', 'FinalSubmissionFile']]
      allow(service).to receive(:release_files).with(original_final_files).and_return(true)

      result = service.unpublish(original_final_files)
      expect(service).to have_received(:release_files).with(original_final_files)
      expect(result).to be true
    end
  end

  describe '#final_files_for_submission' do
    let(:submission) { FactoryBot.create(:submission, :waiting_for_publication_release) }

    context 'when submission has only final submission files' do
      it 'returns id, current_location, and class name for each final file' do
        final_file = FactoryBot.create(:final_submission_file, submission:)

        result = service.final_files_for_submission(submission)

        expect(result).to eq([[final_file.id, final_file.current_location, 'FinalSubmissionFile']])
      end
    end

    context 'when submission has remediated final submission files' do
      it 'includes both original and remediated files' do
        final_file = FactoryBot.create(:final_submission_file, submission:)
        remed_file = FactoryBot.create(:remediated_final_submission_file, submission:, final_submission_file: final_file)

        result = service.final_files_for_submission(submission)

        expect(result).to eq([
                               [final_file.id, final_file.current_location, 'FinalSubmissionFile'],
                               [remed_file.id, remed_file.current_location, 'RemediatedFinalSubmissionFile']
                             ])
      end
    end
  end

  describe '#release_files' do
    let(:locations) do
      [
        [1, '/workflow/path/1.pdf', 'FinalSubmissionFile'],
        [2, '/workflow/path/2.pdf', 'RemediatedFinalSubmissionFile']
      ]
    end

    it 'moves each file using EtdaFilePaths and returns true when all succeed' do
      etda_double = instance_double(EtdaFilePaths)
      allow(EtdaFilePaths).to receive(:new).and_return(etda_double)

      allow(etda_double).to receive(:move_a_file).with(1, '/workflow/path/1.pdf', file_class: FinalSubmissionFile).and_return('')
      allow(etda_double).to receive(:move_a_file).with(2, '/workflow/path/2.pdf', file_class: RemediatedFinalSubmissionFile).and_return('')

      result = service.release_files(locations)
      expect(etda_double).to have_received(:move_a_file).with(1, '/workflow/path/1.pdf', file_class: FinalSubmissionFile)
      expect(etda_double).to have_received(:move_a_file).with(2, '/workflow/path/2.pdf', file_class: RemediatedFinalSubmissionFile)
      expect(result).to be true
    end

    it 'records an error and returns false when move_a_file fails' do
      etda_double = instance_double(EtdaFilePaths)
      allow(EtdaFilePaths).to receive(:new).and_return(etda_double)

      allow(etda_double).to receive(:move_a_file).with(1, '/workflow/path/1.pdf', file_class: FinalSubmissionFile).and_return('Error moving file')
      # The second call should never be reached once an error occurs
      allow(etda_double).to receive(:move_a_file).with(2, '/workflow/path/2.pdf', file_class: RemediatedFinalSubmissionFile)

      allow(service).to receive(:record_error).with('Error moving file')

      result = service.release_files(locations)
      expect(service).to have_received(:record_error).with('Error moving file')
      expect(result).to be false
    end
  end

  describe '#file_verification' do
    let(:files_array) do
      [
        [1, '/workflow/path/1.pdf', 'FinalSubmissionFile'],
        [2, '/workflow/path/2.pdf', 'RemediatedFinalSubmissionFile']
      ]
    end

    it 'returns valid: true when all files exist' do
      allow(File).to receive(:exist?).and_return(true)

      result = service.file_verification(files_array)

      expect(result[:valid]).to be true
      expect(result[:file_error_list]).to be_empty
    end

    it 'records an error and returns valid: false when a file is missing' do
      allow(File).to receive(:exist?).with('/workflow/path/1.pdf').and_return(true)
      allow(File).to receive(:exist?).with('/workflow/path/2.pdf').and_return(false)

      expected_error = 'File Not Found for Remediated final submission file 2, /workflow/path/2.pdf '
      allow(service).to receive(:record_error).with(expected_error)

      result = service.file_verification(files_array)
      expect(service).to have_received(:record_error).with(expected_error)

      expect(result[:valid]).to be false
      expect(result[:file_error_list]).to eq([expected_error])
    end
  end
end
