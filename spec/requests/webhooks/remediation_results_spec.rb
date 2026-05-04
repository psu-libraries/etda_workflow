# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks::RemediationResults', type: :request do
  let(:pdf_api_app) { ExternalApp.pdf_accessibility_api }

  describe 'POST /webhooks/remediation_results' do
    let(:path) { '/webhooks/remediation_results' }
    let(:output_url) { 'http://www.test.com' }
    let(:remediation_job_uuid) { 1 }
    let(:error_message) { nil }
    let(:params) do
      { event_type: event_type,
        job: { uuid: remediation_job_uuid,
               output_url: output_url,
               processing_error_message: error_message } }
    end

    before do
      allow(BuildRemediatedFileWorker).to receive(:perform_async).with(remediation_job_uuid, output_url)
    end

    context 'when remediation has succeeded' do
      let(:event_type) { 'job.succeeded' }

      it 'calls perform_async on BuildSubmissionFileWorker' do
        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => pdf_api_app.token }
        post path, params: params.to_json, headers: headers
        expect(BuildRemediatedFileWorker).to have_received(:perform_async).with(remediation_job_uuid, output_url)
      end
    end

    context 'when remediation has failed' do
      let(:event_type) { 'job.failed' }
      let(:error_message) { 'Some error message' }

      it 'logs the failure message from the PDF API' do
        original_logger = Rails.logger
        log_output = StringIO.new
        Rails.logger = ActiveSupport::Logger.new(log_output)

        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => pdf_api_app.token }
        post path, params: params.to_json, headers: headers
        expect(log_output.string).to include('Some error message')
      ensure
        Rails.logger = original_logger
      end
    end

    context 'when event type is not recognized' do
      let(:event_type) { 'job.other' }

      it 'logs an unrecognized event type' do
        original_logger = Rails.logger
        log_output = StringIO.new
        Rails.logger = ActiveSupport::Logger.new(log_output)

        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => pdf_api_app.token }
        post path, params: params.to_json, headers: headers
        expect(log_output.string).to include('Unknown event type received:')
        expect(log_output.string).to include('other')
      ensure
        Rails.logger = original_logger
      end
    end

    context 'when another error is thrown' do
      let(:event_type) { 'job.succeeded' }

      it 'logs an unrecognized event type' do
        original_logger = Rails.logger
        log_output = StringIO.new
        Rails.logger = ActiveSupport::Logger.new(log_output)
        error = StandardError.new('Another test error')
        error.set_backtrace(["aw dang it"])
        allow(BuildRemediatedFileWorker).to receive(:perform_async).and_raise(error)
        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => pdf_api_app.token }
        post path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:internal_server_error)
        expect(log_output.string).to include("Webhook failed: StandardError - Another test error\naw dang it")
      ensure
        Rails.logger = original_logger
      end
    end
  end
end
