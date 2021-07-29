class DirectoryService
  class << self
    def get_accessid_by_email(email_address)
      parsed_response = JSON.parse(RestClient.get(url(email_address), headers)).first

      return parsed_response if parsed_response.present?

      nil
    end

    private

    def endpoint_url
      "https://prod.apps.psu.edu/directory-service-web/resources/people"
    end

    def query(email_address)
      "?emailAddress=#{email_address}"
    end

    def url(email_address)
      endpoint_url + query(email_address)
    end

    def headers
      { accept: 'application/vnd-psu.edu-v1+json' }
    end
  end
end
