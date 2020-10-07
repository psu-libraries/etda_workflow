require 'model_spec_helper'

RSpec.describe SedFile, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:asset).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

  it { is_expected.to have_db_index(:submission_id) }

  it { is_expected.to validate_presence_of :submission_id }
  it { is_expected.to belong_to :submission }

  it { is_expected.to validate_presence_of :asset }

  it 'returns class name with dashes' do
    sed_file = described_class.new
    expect(sed_file.class_name).to eql('sed-file')
  end

  it '#current_location - returns full path of file including file name' do
    submission = FactoryBot.create :submission, :collecting_final_submission_files
    sed_file = SedFile.new(submission_id: submission.id)
    sed_file.id = 1234
    allow_any_instance_of(SedFile).to receive(:asset_identifier).and_return('stubbed_filename.pdf')
    expect(sed_file.current_location).to eq(WORKFLOW_BASE_PATH + 'sed_files/' + EtdaFilePaths.new.detailed_file_path(sed_file.id) + 'stubbed_filename.pdf')
  end

  it '#full_file_path returns the full file path w/o filename' do
    submission = FactoryBot.create :submission, :collecting_final_submission_files
    sed_file = SedFile.new(submission_id: submission.id)
    sed_file.id = 1234
    expect(sed_file.full_file_path).to eq(WORKFLOW_BASE_PATH + 'sed_files/' + EtdaFilePaths.new.detailed_file_path(sed_file.id))
  end

  describe 'virus scanning' do
    # The .name below is required due to the way Rails reloads classes in
    # development and test modes, can't compare the actual constants
    let(:virus_scan_is_mocked?) { VirusScanner.name == MockVirusScanner.name }

    let(:good_file) { FactoryBot.create :sed_file }

    infected_file = SedFile.new(asset: File.open(fixture('eicar_standard_antivirus_test_file.pdf')))

    it 'validates that the asset is virus free' do
      allow(VirusScanner).to receive(:scan).and_return(object_double('scanner', safe?: true)) if virus_scan_is_mocked?
      good_file.valid?
      expect(good_file.errors[:asset]).to be_empty

      allow(VirusScanner).to receive(:scan).and_return(object_double('scanner', safe?: false)) if virus_scan_is_mocked?
      infected_file.valid?
      expect(infected_file.errors[:asset]).to include I18n.t('errors.messages.virus_free')
    end
  end
end
