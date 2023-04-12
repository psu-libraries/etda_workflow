# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe FormatReviewFile, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:asset).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }

  it { is_expected.to have_db_index(:submission_id) }
  it { is_expected.to have_db_index(:legacy_id) }

  it { is_expected.to validate_presence_of :submission_id }
  it { is_expected.to belong_to :submission }

  # it { is_expected.to validate_presence_of :asset }
  it 'validates the presence of asset when an author is editing' do
    submission = FactoryBot.create :submission, :collecting_committee
    submission.author_edit = true
    submission.status = 'collecting_format_review_files'
    expect(submission).not_to be_valid
  end

  it 'returns class name with dashes' do
    format_review_file = described_class.new
    expect(format_review_file.class_name).to eql('format-review-file')
  end

  it '#current_location - returns full path of file including file name' do
    submission = FactoryBot.create :submission, :collecting_format_review_files
    format_file = described_class.new(submission_id: submission.id)
    format_file.id = 1234
    allow_any_instance_of(described_class).to receive(:asset_identifier).and_return('stubbed_filename.pdf')
    expect(format_file.current_location).to eq("#{WORKFLOW_BASE_PATH}format_review_files/#{EtdaFilePaths.new.detailed_file_path(format_file.id)}stubbed_filename.pdf")
  end

  it '#full_file_path returns the full file path w/o filename' do
    submission = FactoryBot.create :submission, :collecting_format_review_files
    format_review_file = described_class.new(submission_id: submission.id)
    format_review_file.id = 1234
    expect(format_review_file.full_file_path).to eq("#{WORKFLOW_BASE_PATH}format_review_files/#{EtdaFilePaths.new.detailed_file_path(format_review_file.id)}")
  end

  describe 'virus scanning' do
    # The .name below is required due to the way Rails reloads classes in
    # development and test modes, can't compare the actual constants
    let(:virus_scan_is_mocked?) { VirusScanner.name == MockVirusScanner.name }

    let(:good_file) { FactoryBot.create :format_review_file }

    infected_file = described_class.new(asset: File.open(fixture('eicar_standard_antivirus_test_file.txt')))

    it 'validates that the asset is virus free' do
      allow(VirusScanner).to receive(:safe?).and_return(true) if virus_scan_is_mocked?
      good_file.valid?
      expect(good_file.errors[:asset]).to be_empty

      allow(VirusScanner).to receive(:safe?).and_return(false) if virus_scan_is_mocked?
      infected_file.valid?
      expect(infected_file.errors[:asset]).to include I18n.t('errors.messages.virus_free')
    end
  end
end
