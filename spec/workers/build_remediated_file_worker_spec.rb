# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe BuildRemediatedFileWorker do
  let(:final_submission_file) { create(:final_submission_file, :remediate) }
  let(:url) { 'www.fakepdf.pdf' }
  let(:mock_remediated_service) { instance_double(BuildRemediatedFileService, call: nil) }

  before do
    allow(mock_remediated_service).to receive(:call)
    allow(BuildRemediatedFileService).to receive(:new).and_return(mock_remediated_service)
  end

  describe '#perform' do
    it 'initiates a BuildRemediatedFileService with the final submission file and url' do
      described_class.new.perform(final_submission_file.remediation_job_uuid, url)
      expect(BuildRemediatedFileService).to have_received(:new).with(final_submission_file, url)
    end

    it 'calls the BuildRemediatedFileService' do
      described_class.new.perform(final_submission_file.remediation_job_uuid, url)
      expect(mock_remediated_service).to have_received(:call)
    end
  end
end
