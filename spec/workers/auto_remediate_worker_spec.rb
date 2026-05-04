# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoRemediateWorker do
  let(:file) { create(:final_submission_file) }
  let(:expected_download_url) { "http://etda.localhost:3000/files/final_submissions/#{file.id}" }

  describe '#perform' do
    it 'initializes PdfRemediation::Client with the explore download URL, requests remediation, and updates the job UUID' do
      client = instance_double(PdfRemediation::Client, request_remediation: 'uuid-123')
      allow(PdfRemediation::Client).to receive(:new).with(expected_download_url).and_return(client)

      described_class.new.perform(file.id)

      expect(PdfRemediation::Client).to have_received(:new).with(expected_download_url)
      expect(client).to have_received(:request_remediation)
      expect(file.reload.remediation_job_uuid).to eq('uuid-123')
    end

    it 'raises ActiveRecord::RecordNotFound when the file does not exist' do
      expect { described_class.new.perform(file.id + 999_999) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'bubbles up client errors and does not update the job UUID' do
      allow(PdfRemediation::Client).to receive(:new).with(expected_download_url).and_raise(PdfRemediation::Client::MissingConfiguration)

      expect { described_class.new.perform(file.id) }.to raise_error(PdfRemediation::Client::MissingConfiguration)
      expect(file.reload.remediation_job_uuid).to be_nil
    end
  end

  describe '.perform_async' do
    it 'queues the job' do
      Sidekiq::Worker.clear_all
      expect { described_class.perform_async(file.id) }.to change { Sidekiq::Worker.jobs.size }.by(1)
    end

    it 'enqueues on the auto_remediate_out queue' do
      Sidekiq::Worker.clear_all
      described_class.perform_async(file.id)
      job = Sidekiq::Worker.jobs.last
      expect(job['queue']).to eq('auto_remediate_out')
    end
  end
end
