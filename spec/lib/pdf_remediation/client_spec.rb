# frozen_string_literal: true

# This is copied directly from: https://github.com/psu-libraries/scholarsphere/blob/main/spec/lib/pdf_remediation/client.rb
# If this client is used in more than two places, we should consider extracting it into a gem.

require 'spec_helper'
require 'model_spec_helper'
require 'pdf_remediation/client'

RSpec.describe PdfRemediation::Client do
  let(:client) { described_class.new('test url') }
  let(:connection) { instance_double Faraday::Connection }
  let(:request) { instance_spy Faraday::Request }
  let(:response) { instance_double Faraday::Response }
  let!(:endpoint) { ENV['PDF_REMEDIATION_ENDPOINT'] }
  let!(:api_key) { ENV["PDF_REMEDIATION_API_KEY_#{current_partner.id.upcase}"] }

  before do
    allow(Faraday).to receive(:new).with(
      url: endpoint,
      headers: { 'X-API-KEY' => api_key }
    ).and_return connection

    allow(connection).to receive(:post).and_yield(request).and_return(response)
    allow(response).to receive_messages(status: 200, body: %{{"uuid": "uuid-123"}})
  end

  after do
    ENV["PDF_REMEDIATION_API_KEY_#{current_partner.id.upcase}"] = "testValue"
    ENV['PDF_REMEDIATION_ENDPOINT'] = "testValue"
  end


  describe '#request_remediation', :honors, :milsch do
    context 'when PDF_REMEDIATION_ENDPOINT has not been configured' do
      before do
        ENV['PDF_REMEDIATION_ENDPOINT'] = nil
      end

      it 'raises an error' do
        expect { client.request_remediation }.to raise_error PdfRemediation::Client::MissingConfiguration
      end
    end

    context 'when PDF_REMEDIATION_API_KEY for the current partner has not been configured' do
      before do
        ENV["PDF_REMEDIATION_API_KEY_#{current_partner.id.upcase}"] = nil
      end

      it 'raises an error' do
        expect { client.request_remediation }.to raise_error PdfRemediation::Client::MissingConfiguration
      end
    end

    context 'when Faraday::Error is raised' do
      before { allow(connection).to receive(:post).and_raise Faraday::Error }

      it 'raises an error' do
        expect { client.request_remediation }.to raise_error PdfRemediation::Client::ConnectionError
      end
    end

    it 'posts the given URL to the PDF remediation endpoint' do
      client.request_remediation
      expect(request).to have_received(:body=).with({ source_url: 'test url' })
    end

    context 'when the request to the endpoint returns a 200 response' do
      it 'returns the UUID of the remediation job that was created' do
        expect(client.request_remediation).to eq 'uuid-123'
      end
    end

    context 'when the request to the endpoint returns a 401 response' do
      before { allow(response).to receive(:status).and_return 401 }

      it 'raises an error' do
        expect { client.request_remediation }.to raise_error PdfRemediation::Client::InvalidAPIKey
      end
    end

    context 'when the request to the endpoint returns a 422 response' do
      before { allow(response).to receive(:status).and_return 422 }

      it 'raises an error' do
        expect { client.request_remediation }.to raise_error PdfRemediation::Client::InvalidFileURL
      end
    end

    context 'when the request to the endpoint returns an unexpected response' do
      before do
        allow(response).to receive_messages(status: 302, body: 'Redirecting')
      end

      it 'raises an error' do
        expect { client.request_remediation }.to raise_error RuntimeError, /Unexpected response: 302 - Redirecting/
      end
    end
  end
end
