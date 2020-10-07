require 'model_spec_helper'

RSpec.describe AncillaryFile do
  # Using proquest file ass an example to test AncillaryFile methods
  let!(:ancillary_file) { FactoryBot.create :proquest_file }

  it 'returns class name with dashes' do
    expect(ancillary_file.class_name).to eql('proquest-file')
  end

  it '#current_location - returns full path of file including file name' do
    submission = FactoryBot.create :submission, :collecting_final_submission_files
    ancillary_file.submission_id = submission.id
    ancillary_file.id = 1234
    allow_any_instance_of(ProquestFile).to receive(:asset_identifier).and_return('stubbed_filename.pdf')
    expect(ancillary_file.current_location).to eq(WORKFLOW_BASE_PATH + 'proquest_files/' + EtdaFilePaths.new.detailed_file_path(ancillary_file.id) + 'stubbed_filename.pdf')
  end

  it '#full_file_path returns the full file path w/o filename' do
    submission = FactoryBot.create :submission, :collecting_final_submission_files
    ancillary_file.submission_id = submission.id
    ancillary_file.id = 1234
    expect(ancillary_file.full_file_path).to eq(WORKFLOW_BASE_PATH + 'proquest_files/' + EtdaFilePaths.new.detailed_file_path(ancillary_file.id))
  end
end