require 'httparty'

class Lionpath::LionpathExport
  def initialize(submission)
    @payload = Lionpath::LionpathExportPayload.new(submission)
  end

  def call
    options = {
      body: payload.json_payload,
      headers: {
        'Content-Type' => 'application/json',
        'Content-Transfer-Encoding' => 'application/json'
      },
      basic_auth: auth
    }

    response = HTTParty.put(host + endpoint_path, options)
    raise response.message unless response.code == 200

    raise response.parsed_response["PE_SR199_ETD_FAULT"]["errorMsg"] unless response.parsed_response["PE_SR199_ETD_FAULT"]["errorNbr"] == 200

    nil
  end

  private

    attr_accessor :payload

    def auth
      { username: ENV.fetch('LP_SA_USERNAME', 'test_user'),
        password: ENV.fetch('LP_SA_PASSWORD', 'test_password') }
    end

    def host
      ENV.fetch('LP_EXPORT_HOST', 'abcdef')
    end

    def endpoint_path
      "/PSIGW/RESTListeningConnector/PSFT_HR/PE_SR199_ETD_INPUT.v1/update"
    end
end
