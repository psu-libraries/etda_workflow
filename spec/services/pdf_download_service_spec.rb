# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfDownloadService do
  let(:final_submission_file) { create(:final_submission_file) }
  let(:pdf_url) { 'https://www.example.com/fakepdf.pdf' }
  let(:bogus_url) { 'https://www.example.com/fakepdf.jpg' }
  let(:pdf_path) { Rails.root.join('spec/fixtures/files/final_submission_file_01.pdf') }
  let(:pdf_bytes) { File.binread(pdf_path) }

  before do
    stub_request(:get, pdf_url)
      .to_return(
        status: 200,
        body: pdf_bytes,
        headers: { "Content-Type" => "application/pdf" }
      )
  end

  describe '#call' do
    it 'creates a new RemediatedFinalSubmissionFile with the pdf as an asset' do
      expect(RemediatedFinalSubmissionFile.count).to eq(0)

      service = described_class.new(final_submission_file, pdf_url)
      service.call
      expect(RemediatedFinalSubmissionFile.count).to eq(1)
    end

    context 'if the url does not end with pdf' do
      it 'returns an error' do
        service = described_class.new(final_submission_file, bogus_url)
        expect { service.call }.to raise_error(PdfDownloadService::DownloadError)
      end
    end
  end
end
