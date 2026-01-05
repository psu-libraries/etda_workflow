require 'model_spec_helper'

RSpec.describe PdfDownloadWorker do
  let(:final_submission_file) { create(:final_submission_file)}
  let(:url) {'www.fakepdf.pdf'}
  let(:mock_pdf_download_service) { instance_double(PdfDownloadService, call: nil) }

  before do
    allow(mock_pdf_download_service).to receive(:call)
    allow(PdfDownloadService).to receive(:new).and_return(mock_pdf_download_service)
  end
  describe '#perform' do
    it 'initiates a PdfDownloadService with the final submission file and url' do
      described_class.new.perform(final_submission_file, url)
      expect(PdfDownloadService).to have_received(:new).with(final_submission_file, url)
    end

    it 'calls the PdfDownloadService' do
      described_class.new.perform(final_submission_file, url)
      expect(mock_pdf_download_service).to have_received(:call)
    end
  end
end
