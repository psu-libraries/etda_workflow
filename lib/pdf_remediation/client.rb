# frozen_string_literal: true

# This is copied directly from: https://github.com/psu-libraries/scholarsphere/blob/main/lib/pdf_remediation/client.rb
# If this client is used in more than two places, we should consider extracting it into a gem.

require 'faraday'

module PdfRemediation
  class Client
    class MissingConfiguration < RuntimeError; end
    class InvalidAPIKey < RuntimeError; end
    class InvalidFileURL < RuntimeError; end
    class ConnectionError < RuntimeError; end

    def initialize(file_url)
      @file_url = file_url
    end

    def request_remediation
      response = connection.post do |req|
        req.body = { source_url: file_url }
      end

      case response.status
      when 200
        JSON.parse(response.body)['uuid']
      when 401
        raise InvalidAPIKey
      when 422
        raise InvalidFileURL
      else
        raise "Unexpected response: #{response.status} - #{response.body}"
      end
    rescue Faraday::Error => e
      raise ConnectionError, e
    end

    private

      attr_reader :file_url

      def connection
        @connection ||= Faraday.new(
          url: endpoint,
          headers: { 'X-API-KEY' => api_key }
        )
      end

      def endpoint
        @endpoint ||= ENV['PDF_REMEDIATION_ENDPOINT'] or raise(MissingConfiguration, 'PDF_REMEDIATION_ENDPOINT is not set')
      end

      def api_key
        @api_key ||= ENV['PDF_REMEDIATION_API_KEY'] or raise(MissingConfiguration, 'PDF_REMEDIATION_API_KEY is not set')
      end
  end
end
