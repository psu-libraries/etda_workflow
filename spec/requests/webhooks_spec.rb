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
end
