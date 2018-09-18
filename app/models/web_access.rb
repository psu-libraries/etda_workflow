# frozen_string_literal: true

class WebAccess
  BASE_LOGIN_URL = 'https://webaccess.psu.edu/?factors=dce.psu.edu&cosign-%s&%s'
  BASE_LOGOUT_URL = 'https://webaccess.psu.edu/cgi-bin/logout?%s'
  def initialize(redirect_url_in = '')
    @redirect_url = redirect_url_in.presence || application_url
  end

  def login_url
    format(WebAccess::BASE_LOGIN_URL, service, @redirect_url)
  end

  def logout_url
    format(WebAccess::BASE_LOGOUT_URL, service)
  end

  def login_url_path
    "?factors=dce.psu.edu&cosign-#{service}&#{@redirect_url}"
  end

  def explore_base_url
    # replace workflow with explore for qa, stage, and dev
    # remove workflow completely for prod instance
    this_url = application_url
    replace_wf = explore_url_string(this_url)
    this_url.sub(/-workflow/, replace_wf)
  end

  private

  def application_url
    Rails.application.secrets.webaccess[:vservice]
  end

  def service
    url = Rails.application.secrets.webaccess[:vservice]
    uri = URI.parse(url)
    uri.host
  end

  def explore_url_string(this_url)
    str = ''
    str = '-explore' if ['-stage', '-qa', '-dev'].any? { |not_prod| this_url.include? not_prod }
    str
  end
end
