class WebAccess
  BASE_LOGIN_URL = 'https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-%s&%s'
  BASE_LOGOUT_URL = 'https://webaccess.psu.edu/cgi-bin/logout?%s'

  def initialize(redirect_url_in = '')
    @redirect_url = redirect_url_in.blank? ? application_url : redirect_url_in
  end

  def login_url
    format(WebAccess::BASE_LOGIN_URL, service, @redirect_url)
  end

  def logout_url
    format(WebAccess::BASE_LOGOUT_URL, Rails.application.secrets.webaccess[:vservice])
  end

  private

    def application_url
      Rails.application.secrets.webaccess[:vhost]
    end

    def service
      Rails.application.secrets.webaccess[:vservice]
    end
end
