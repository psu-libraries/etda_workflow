# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe RemediatedFinalSubmissionFile, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:asset).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

  it { is_expected.to have_db_index(:submission_id) }
  it { is_expected.to have_db_index(:final_submission_file_id) }

  it { is_expected.to validate_presence_of :asset }
  it { is_expected.to validate_presence_of :submission_id }

  it { is_expected.to belong_to :submission }
  it { is_expected.to belong_to :final_submission_file }

  it 'returns class name with dashes' do
    expect(described_class.new.class_name).to eql('remediated-final-submission-file')
  end

  describe '#full_file_path' do
    context 'when submission is waiting for publication release' do
      it 'returns full workflow file path w/o filename' do
        submission = FactoryBot.create :submission, :waiting_for_publication_release
        final_submission_file = described_class.new(submission_id: submission.id)
        final_submission_file.id = 1234
        expect(final_submission_file.full_file_path)
          .to eq(
            "#{WORKFLOW_BASE_PATH}final_submission_files/#{EtdaFilePaths.new.detailed_file_path(final_submission_file.id, remediated: true)}"
          )
      end
    end

    context 'when submission has been released for publication' do
      it 'returns full explore file path w/o filename' do
        submission = FactoryBot.create :submission, :released_for_publication
        final_submission_file = described_class.new(submission_id: submission.id)
        final_submission_file.id = 1234
        expect(final_submission_file.full_file_path)
          .to eq(
            "#{EXPLORE_BASE_PATH + submission.access_level_key}/#{EtdaFilePaths.new.detailed_file_path(final_submission_file.id, remediated: true)}"
          )
      end
    end
  end

  describe 'virus scanning' do
    # We have these Virus scanner tests for both format review file and final_submission_file models
    # Not sure if it's valauble to have them here as well?

    let(:virus_scan_is_mocked?) { VirusScanner.name == MockVirusScanner.name }

    let(:good_file) { build :remediated_final_submission_file }

    let(:infected_file) { described_class.new(asset: File.open(file_fixture('final_submission_file_01.pdf'))) }

    it 'validates that the asset is virus free' do
      allow(VirusScanner).to receive(:safe?).and_return(true) if virus_scan_is_mocked?
      good_file.valid?
      expect(good_file.errors[:asset]).to be_empty

      allow(VirusScanner).to receive(:safe?).and_return(false) if virus_scan_is_mocked?
      infected_file.valid?
      expect(infected_file.errors[:asset]).to include I18n.t('errors.messages.virus_free')
    end
  end

  describe '#asset' do
    context "after a file has been saved" do
      let(:file1) { FactoryBot.create :remediated_final_submission_file }

      describe '#read' do
        it "provides an open IO stream to the file contents" do
          expect(file1.asset.read).not_to be_blank
        end
      end

      describe '#content_type' do
        it "returns the content type for the file" do
          expect(file1.asset.content_type).to eq "application/pdf"
        end
      end
    end
  end

  describe 'after_save :move_file' do
    let(:submission) { FactoryBot.create :submission, :released_for_publication }
    let(:remediated_file) { FactoryBot.create :remediated_final_submission_file, submission: submission }

    it 'calls EtdaFilePaths.move_a_file with remediated_file: true' do
      path_builder = instance_double(EtdaFilePaths)
      allow(EtdaFilePaths).to receive(:new).and_return(path_builder)
      allow(path_builder).to receive(:detailed_file_path).and_return('path/to/file/')
      allow(path_builder).to receive(:move_a_file)

      original_file_location = "#{WORKFLOW_BASE_PATH}final_submission_files/#{path_builder.detailed_file_path(remediated_file.id, remediated: true)}#{remediated_file.asset_identifier}"

      remediated_file.save!

      # Expect twice: once during create, once during save!
      expect(path_builder).to have_received(:move_a_file).with(remediated_file.id, original_file_location, file_class: remediated_file.class).twice
    end
  end
end
