require 'model_spec_helper'

RSpec.describe Lionpath::LionpathExport do
  subject(:exporter) { described_class.new(submission) }

  let(:submission) { instance_double('Submission') }
  let(:payload_instance) { instance_double('Lionpath::LionpathExportPayload', json_payload:) }
  let(:json_payload) { '{"PE_SR199_ETD_REQ":{"key":"value"}}' }
  let(:auth) { ['test_user', 'test_password'] }
  let(:host) { 'https://test.com' }
  let(:endpoint_path) { '/PSIGW/RESTListeningConnector/PSFT_HR/PE_SR199_ETD_INPUT.v1/update' }
  let(:full_url) { host + endpoint_path }
  let(:headers) { { 'Content-Type' => 'application/json', 'Content-Transfer-Encoding' => 'application/json' } }
  let(:options) { { body: json_payload, headers:, basic_auth: auth } }

  before do
    allow(Lionpath::LionpathExportPayload).to receive(:new).with(submission).and_return(payload_instance)
    allow(ENV).to receive(:fetch).with('LP_SA_USERNAME', 'test_user').and_return('test_user')
    allow(ENV).to receive(:fetch).with('LP_SA_PASSWORD', 'test_password').and_return('test_password')
    allow(ENV).to receive(:fetch).with('LP_EXPORT_HOST', 'abcdef').and_return('https://test.com')
  end

  describe '#call' do
    context 'when the response is successful' do
      before do
        stub_request(:put, full_url)
          .with(options)
          .to_return(status: 200,
                     body: '{"PE_SR199_ETD_FAULT":{"errorNbr":200}}',
                     headers:)
      end

      it 'does not raise an error' do
        expect { exporter.call }.not_to raise_error
      end
    end

    context 'when the response is unsuccessful' do
      before do
        stub_request(:put, full_url)
          .with(options)
          .to_return(status: [401, "Unauthorized"],
                     body: '',
                     headers:)
      end

      it 'raises an error with the response message' do
        expect { exporter.call }.to raise_error('Unauthorized')
      end
    end

    context 'when the response is successful but the API contains an error number 400' do
      before do
        stub_request(:put, full_url)
          .with(options)
          .to_return(status: 200,
                     body: '{"PE_SR199_ETD_FAULT":{"errorNbr":400,"errorMsg":"Error occurred"}}',
                     headers:)
      end

      it 'raises an error with the parsed response error message' do
        expect { exporter.call }.to raise_error('Error occurred')
      end
    end
  end
end
