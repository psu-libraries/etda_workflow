# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks::AutoRemediate', type: :request do
  let(:explore_app) { ExternalApp.etda_explore }

  describe 'POST /webhooks/auto_remediate' do
    let(:path) { '/webhooks/auto_remediate' }

    context 'when X-API-KEY is valid' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'X-API-KEY' => explore_app.token } }

      context 'when final_submission_file_id is not missing' do
        let!(:final_submission) { FactoryBot.create(:submission) }
        let!(:final_submission_file) { FactoryBot.create(:final_submission_file, submission: final_submission) }
        let!(:final_submission_file_2) { FactoryBot.create(:final_submission_file, submission: final_submission) }

        it 'returns 200, sets remediation_started_at, and queues the job' do
          expect(final_submission_file.remediation_started_at).to be_nil
          expect(final_submission_file_2.remediation_started_at).to be_nil

          allow(AutoRemediateWorker).to receive(:perform_async)
          post path, params: { final_submission_file_id: final_submission_file.id }.to_json, headers: headers

          expect(response).to have_http_status(:ok)
          expect(final_submission_file.reload.remediation_started_at).not_to be_nil
          expect(final_submission_file_2.reload.remediation_started_at).not_to be_nil
          expect(AutoRemediateWorker).to have_received(:perform_async).with(final_submission_file.id)
          expect(AutoRemediateWorker).to have_received(:perform_async).with(final_submission_file_2.id)
        end

        context 'when remediation_started_at is already set' do
          let!(:final_submission_file) do
            FactoryBot.create(:final_submission_file,
                              remediation_started_at: Time.current,
                              submission: final_submission)
          end

          it 'returns 200 but only queues the job for non-remediated files' do
            allow(AutoRemediateWorker).to receive(:perform_async)
            post path, params: { final_submission_file_id: final_submission_file.id }.to_json, headers: headers

            expect(AutoRemediateWorker).not_to have_received(:perform_async).with(final_submission_file.id)
            expect(AutoRemediateWorker).to have_received(:perform_async).with(final_submission_file_2.id)
            expect(response).to have_http_status(:ok)
            expect(final_submission_file.reload.remediation_started_at).not_to be_nil
            expect(final_submission_file_2.reload.remediation_started_at).not_to be_nil
          end
        end

        context 'when remediated_final_submission_file is already present' do
          let!(:final_submission_file) do
            FactoryBot.create(:final_submission_file, submission: final_submission)
          end

          it 'returns 200 but only queues the job for non-remediated files' do
            FactoryBot.create(:remediated_final_submission_file,
                              final_submission_file: final_submission_file)
            allow(AutoRemediateWorker).to receive(:perform_async)
            post path, params: { final_submission_file_id: final_submission_file.id }.to_json, headers: headers

            expect(AutoRemediateWorker).not_to have_received(:perform_async).with(final_submission_file.id)
            expect(AutoRemediateWorker).to have_received(:perform_async).with(final_submission_file_2.id)
            expect(response).to have_http_status(:ok)
            expect(final_submission_file.reload.remediation_started_at).to be_nil
            expect(final_submission_file_2.reload.remediation_started_at).not_to be_nil
          end
        end

        context 'when file is not a PDF' do
          let(:final_submission_file) do
            FactoryBot.create(:final_submission_file, :jpg)
          end

          it 'returns 200 but does not queue the job' do
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
end
