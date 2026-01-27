# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildRemediatedFileService do
  let(:final_submission_file) { create(:final_submission_file) }
  let(:pdf_url) { 'https://www.example.com/fakepdf.pdf' }
  let(:bogus_url) { 'https://www.example.com/fakepdf.jpg' }
  let(:pdf_path) { Rails.root.join('spec/fixtures/files/final_submission_file_01.pdf') }
  let(:pdf_bytes) { File.binread(pdf_path) }
  let(:solr_service) { instance_double('SolrDataImportService', index_submission: nil) }

  before do
    stub_request(:get, pdf_url)
      .to_return(
        status: 200,
        body: pdf_bytes,
        headers: { "Content-Type" => "application/pdf" }
      )
    allow(SolrDataImportService).to receive(:new).and_return(solr_service)
  end

  describe '#call' do
    it 'creates a new RemediatedFinalSubmissionFile with the pdf as an asset' do
      expect(RemediatedFinalSubmissionFile.count).to eq(0)

      service = described_class.new(final_submission_file, pdf_url)
      service.call
      expect(RemediatedFinalSubmissionFile.count).to eq(1)
      expect(RemediatedFinalSubmissionFile.first.final_submission_file_id).to eq(final_submission_file.id)
      expect(RemediatedFinalSubmissionFile.first.submission_id).to eq(final_submission_file.submission_id)
    end

    it 'reindexes the submission related to the remediated file' do
      service = described_class.new(final_submission_file, pdf_url)
      service.call
      expect(solr_service).to have_received(:index_submission).with(final_submission_file.submission, true)
    end

    context 'if Down throws an error' do
      before do
        allow(Down).to receive(:download).and_raise(Down::Error.new('download error'))
      end

      it 'returns a Download error' do
        service = described_class.new(final_submission_file, bogus_url)
        expect { service.call }.to raise_error(BuildRemediatedFileService::DownloadError)
      end
    end
  end
end
