class DirectoryService
  class << self
    def get_accessid_by_email(email_address)
      parsed_response = JSON.parse(HTTParty.get(url(email_address), headers)).first

      return parsed_response.first if parsed_response.present?

      nil
    end

    private

      def endpoint_url
        "#{endpoint}/directory-service-web/resources/people"
      end

      def query(email_address)
        "?emailAddress=#{email_address}"
      end

      def url(email_address)
        endpoint_url + query(email_address)
      end

      def headers
        { accept: 'application/vnd-psu.edu-v1+json', Authorization: "Bearer #{token}" }
      end

      def token
        oauth_client = OAuth2::Client.new(client_id,
                                          client_secret, site: oauth_endpoint,
                                                         authorize_url: '/oauth/api/authz',
                                                         token_url: '/oauth/api/token')
        oauth_token = oauth_client.client_credentials.get_token
        oauth_token.token
      end

      def client_id
        @client_id ||= ENV.fetch('PSU_ID_OAUTH_CLIENT_ID')
      end

      def client_secret
        @client_secret ||= ENV.fetch('PSU_ID_OAUTH_CLIENT_SECRET')
      end

      def oauth_endpoint
        @oauth_endpoint ||= ENV.fetch('PSU_ID_OAUTH_ENDPOINT', 'https://acceptance-oauth2-server.qa.k8s.psu.edu')
      end

      def endpoint
        @endpoint ||= ENV.fetch('DIRECTORY_SERVICE_ENDPOINT', 'https://acceptance-directory-service.qa.k8s.psu.edu')
      end
  end
end