# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks', type: :request do
  describe 'POST /webhooks/auto_remediate' do
    let(:path) { '/webhooks/auto_remediate' }

    before do
      @orig_secret = ENV['AUTO_REMEDIATE_WEBHOOK_SECRET']
      ENV['AUTO_REMEDIATE_WEBHOOK_SECRET'] = 'secret-token'
    end

    after do
      if @orig_secret.nil?
        ENV.delete('AUTO_REMEDIATE_WEBHOOK_SECRET')
      else
        ENV['AUTO_REMEDIATE_WEBHOOK_SECRET'] = @orig_secret
      end
    end

    context 'when AUTO_REMEDIATE_WEBHOOK_SECRET is set' do
      context 'when X-API-KEY is valid' do
        context 'when final_submission_file_id is not missing' do
          it 'returns 200 and queues the job' do
            allow(AutoRemediateWorker).to receive(:perform_async)
            headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'secret-token' }
            post path, params: { final_submission_file_id: 'data' }.to_json, headers: headers
            expect(response).to have_http_status(:ok)
            expect(AutoRemediateWorker).to have_received(:perform_async).with('data')
          end
        end

        context 'when final_submission_file_id is missing' do
          it 'returns 400' do
            headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'secret-token' }
            post path, params: {}.to_json, headers: headers
            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'when StandardError occurs' do
          it 'returns 500' do
            original_logger = Rails.logger
            log_output = StringIO.new
            Rails.logger = ActiveSupport::Logger.new(log_output)
            error = StandardError.new('Test error')
            error.set_backtrace(["/path/to/file.rb:10:in `method_name'"])
            allow(AutoRemediateWorker).to receive(:perform_async).and_raise(error)
            headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'secret-token' }
            post path, params: { final_submission_file_id: 'data' }.to_json, headers: headers
            expect(response).to have_http_status(:internal_server_error)
            expect(log_output.string).to include("Webhook failed: StandardError - Test error\n/path/to/file.rb:10:in `method_name'")
          ensure
            Rails.logger = original_logger
          end
        end
      end

      context 'when X-API-KEY is invalid' do
        it 'returns 401' do
          headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'wrong-token' }
          post path, params: { final_submission_file_id: 'data' }.to_json, headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when X-API-KEY is missing' do
        it 'returns 401' do
          headers = { 'CONTENT_TYPE' => 'application/json' }
          post path, params: { final_submission_file_id: 'data' }.to_json, headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when AUTO_REMEDIATE_WEBHOOK_SECRET is not set' do
        before do
          ENV.delete('AUTO_REMEDIATE_WEBHOOK_SECRET')
        end

        it 'returns 401' do
          headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'secret-token' }
          post path, params: { final_submission_file_id: 'data' }.to_json, headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe 'POST /webhooks/handle_remediation_results' do
    let(:path) { '/webhooks/handle_remediation_results' }
    let(:output_url) { 'http://www.test.com' }
    let(:job_uuid) { 1 }
    let(:error_message) { nil }
    let(:params) do
      { event_type: event_type,
        job: { uuid: job_uuid,
              output_url: output_url,
              processing_error_message: error_message } }
    end

    before do
      allow(BuildRemediatedFileWorker).to receive(:perform_later).with(job_uuid, output_url)
      @orig_secret = ENV['AUTO_REMEDIATE_WEBHOOK_SECRET']
      ENV['AUTO_REMEDIATE_WEBHOOK_SECRET'] = 'secret-token'
    end

    after do
      if @orig_secret.nil?
        ENV.delete('AUTO_REMEDIATE_WEBHOOK_SECRET')
      else
        ENV['AUTO_REMEDIATE_WEBHOOK_SECRET'] = @orig_secret
      end
    end

    context 'when remediation has succeeded' do
      let(:event_type) { 'job.succeeded' }
      it 'calls perform_later on BuildSubmissionFileWorker' do
        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'secret-token' }
        post path, params: params.to_json, headers: headers
        expect(BuildRemediatedFileWorker).to have_received(:perform_later).with(job_uuid, output_url)
      end
    end

    context 'when remediation has failed' do
      let(:event_type) { 'job.failed' }
      let(:error_message) { 'Some error message'}
      it 'logs the failure message from the PDF API' do
        original_logger = Rails.logger
        log_output = StringIO.new
        Rails.logger = ActiveSupport::Logger.new(log_output)

        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'secret-token' }
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

        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'secret-token' }
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
        allow(BuildRemediatedFileWorker).to receive(:perform_later).and_raise(error)
        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => 'secret-token' }
        post path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:internal_server_error)
        expect(log_output.string).to include("Webhook failed: StandardError - Another test error\naw dang it")
      ensure
        Rails.logger = original_logger
      end
    end
  end
end
