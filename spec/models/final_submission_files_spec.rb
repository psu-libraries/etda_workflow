# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe FinalSubmissionFile, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:asset).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:remediation_started_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:remediation_job_uuid).of_type(:string) }

  it { is_expected.to have_db_index(:submission_id) }
  it { is_expected.to have_db_index(:legacy_id) }

  it { is_expected.to validate_presence_of :asset }
  it { is_expected.to validate_presence_of :submission_id }

  it { is_expected.to belong_to :submission }

  it { is_expected.to have_one :remediated_final_submission_file }

  it 'returns class name with dashes' do
    final_submission_file = described_class.new
    expect(final_submission_file.class_name).to eql('final-submission-file')
  end

  it '#current_location returns full path and filename' do
    submission = FactoryBot.create :submission, :waiting_for_publication_release
    final_submission_file = described_class.new(submission_id: submission.id)
    final_submission_file.id = 1234
    allow_any_instance_of(described_class).to receive(:asset_identifier).and_return('stubbed_filename.pdf')
    expect(final_submission_file.current_location).to eq("#{WORKFLOW_BASE_PATH}final_submission_files/#{EtdaFilePaths.new.detailed_file_path(final_submission_file.id)}stubbed_filename.pdf")
  end

  it '#full_file_path returns the full file path w/o filename' do
    submission = FactoryBot.create :submission, :waiting_for_publication_release
    final_submission_file = described_class.new(submission_id: submission.id)
    final_submission_file.id = 1234
    expect(final_submission_file.full_file_path).to eq("#{WORKFLOW_BASE_PATH}final_submission_files/#{EtdaFilePaths.new.detailed_file_path(final_submission_file.id)}")
  end

  describe 'virus scanning' do
    # The .name below is required due to the way Rails reloads classes in
    # development and test modes, can't compare the actual constants
    let(:virus_scan_is_mocked?) { VirusScanner.name == MockVirusScanner.name }

    let(:good_file) { build :final_submission_file }

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
      let(:file1) { FactoryBot.create :final_submission_file, :pdf }

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
end
