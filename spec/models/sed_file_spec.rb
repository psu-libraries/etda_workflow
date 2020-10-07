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

  describe '#root_files_path' do
    it 'returns the directory above the WORKFLOW_BASE_PATH' do
      expect(described_class.new.send(:root_files_path)).to eq 'sed_files/'
    end
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
