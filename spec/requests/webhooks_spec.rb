# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks', type: :request do
  let(:external_app) { ExternalApp.pdf_accessibility_api }

  describe 'POST /webhooks/auto_remediate' do
    let(:path) { '/webhooks/auto_remediate' }

    context 'when X-API-KEY is valid' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => external_app.token } }

      context 'when final_submission_file_id is not missing' do
        let(:final_submission_file) { FactoryBot.create(:final_submission_file) }

        it 'returns 200, sets remediation_started_at, and queues the job' do
          expect(final_submission_file.remediation_started_at).to be_nil

          allow(AutoRemediateWorker).to receive(:perform_async)
          post path, params: { final_submission_file_id: final_submission_file.id }.to_json, headers: headers

          expect(response).to have_http_status(:ok)
          expect(final_submission_file.reload.remediation_started_at).not_to be_nil
          expect(AutoRemediateWorker).to have_received(:perform_async).with(final_submission_file.id)
        end

        context 'when remediation_started_at is already set' do
          let(:final_submission_file) do
            FactoryBot.create(:final_submission_file,
                              remediation_started_at: Time.current)
          end

          it 'returns 200 but does not queue the job' do
            allow(AutoRemediateWorker).to receive(:perform_async)
            post path, params: { final_submission_file_id: final_submission_file.id }.to_json, headers: headers

            expect(AutoRemediateWorker).not_to have_received(:perform_async)
            expect(response).to have_http_status(:ok)
            expect(final_submission_file.reload.remediation_started_at).not_to be_nil
          end
        end

        context 'when remediated_final_submission_file is already present' do
          let(:final_submission_file) do
            FactoryBot.create(:final_submission_file)
          end

          it 'returns 200 but does not queue the job' do
            FactoryBot.create(:remediated_final_submission_file,
                              final_submission_file: final_submission_file)
            allow(AutoRemediateWorker).to receive(:perform_async)
            post path, params: { final_submission_file_id: final_submission_file.id }.to_json, headers: headers

            expect(AutoRemediateWorker).not_to have_received(:perform_async)
            expect(response).to have_http_status(:ok)
            expect(final_submission_file.reload.remediation_started_at).to be_nil
          end
        end
      end

      context 'when final_submission_file_id is missing' do
        it 'returns 400' do
          post path, params: {}.to_json, headers: headers
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when StandardError occurs' do
        it 'returns 500 and logs error; the timestamp is still set' do
          original_logger = Rails.logger
          log_output = StringIO.new
          Rails.logger = ActiveSupport::Logger.new(log_output)
          error = StandardError.new('Test error')
          error.set_backtrace(["/path/to/file.rb:10:in `method_name'"])
          allow(AutoRemediateWorker).to receive(:perform_async).and_raise(error)
          final_submission_file = FactoryBot.create(:final_submission_file)
          post path, params: { final_submission_file_id: final_submission_file.id }.to_json, headers: headers
          expect(response).to have_http_status(:internal_server_error)
          expect(log_output.string).to include("Webhook failed: StandardError - Test error\n/path/to/file.rb:10:in `method_name'")
          expect(final_submission_file.reload.remediation_started_at).not_to be_nil
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
  end

  describe 'POST /webhooks/handle_remediation_results' do
    let(:path) { '/webhooks/handle_remediation_results' }
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
        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => external_app.token }
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

        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => external_app.token }
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

        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => external_app.token }
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
        headers = { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => external_app.token }
        post path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:internal_server_error)
        expect(log_output.string).to include("Webhook failed: StandardError - Another test error\naw dang it")
      ensure
        Rails.logger = original_logger
      end
    end
  end
end
