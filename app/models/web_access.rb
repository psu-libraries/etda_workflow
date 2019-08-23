# frozen_string_literal: true

class WebAccess
  BASE_LOGIN_URL = 'https://webaccess.psu.edu/?cosign-%s&%s'
  BASE_LOGOUT_URL = 'https://webaccess.psu.edu/cgi-bin/logout?%s'
  def initialize(redirect_url_in = '')
    @redirect_url = redirect_url_in.presence || redirect_url
  end

  def login_url
    format(WebAccess::BASE_LOGIN_URL, service, @redirect_url)
  end

  def logout_url
    format(WebAccess::BASE_LOGOUT_URL, service)
  end

  def login_url_path
    "?cosign-#{service}&#{@redirect_url}"
  end

  private

  def application_url
    return 'https://myapp-workflow.psu.edu' if Rails.env.test?

    ApplicationUrl.current
  end

  def service
    return '' if application_url.nil?

    uri = URI.parse(application_url)
    uri.host
  end

  def redirect_url
    this_url = application_url.chomp('/login')
    this_url = this_url.chomp('/logout')
    this_url
  end
end
