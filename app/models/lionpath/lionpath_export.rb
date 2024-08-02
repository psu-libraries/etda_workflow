require 'httparty'

class LionpathExport
  def initialize(submission)
    @payload = LpExportPayload.new(submission).to_json
  end

  def call
    options = {
      body: payload.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Content-Transfer-Encoding' => 'application/json'
      },
      basic_auth: auth
    }

    self.class.put(base_uri + endpoint_path, options)
  end

  private

    attr_accessor :payload

    def auth
      { username: ENV['LP_SA_USERNAME'],
        password: ENV['LP_SA_PASSWORD'] }
    end

    def base_uri
      ENV['LP_EXPORT_HOST']
    end

    def endpoint_path
      "/PSIGW/RESTListeningConnector/PSFT_HR/PE_SR199_ETD_INPUT.v1/update"
    end
end
