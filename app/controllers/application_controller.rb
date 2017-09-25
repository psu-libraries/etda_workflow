class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :clear_session_author
  before_action :configure_permitted_parameters, if: :devise_controller?

  def clear_session_author
    if request.nil?
      logger.warn "Request is Nil, how weird!!!"
      return
    end
    # only logout if the REMOTE_USER is not set in the HTTP headers and a user is set within warden
    # logout clears the entire session including flash messages
    request.env['warden'].logout unless author_logged_in?
  end

  def login
    webaccess_login_url = WebAccess.new(request.env['HTTP_REFERER']).login_url unless author_logged_in?
    Rails.logger.info "REDIRECTING---" + "#{webaccess_login_url}  #{Time.zone.now}"
    redirect_to webaccess_login_url
  end

  def logout
    # make any local additions here (e.g. expiring local sessions, etc.)
    # adapted from here: http://cosign.git.sourceforge.net/git/gitweb.cgi?p=cosign/cosign;a=blob;f=scripts/logout/logout.php;h=3779248c754001bfa4ea8e1224028be2b978f3ec;hb=HEAD
    cookies.delete(request.env['COSIGN_SERVICE']) if request.env['COSIGN_SERVICE']
    redirect_to WebAccess.new.logout_url
  end

  protected

    def author_logged_in?
      author_signed_in? && Devise::Strategies::WebaccessAuthenticatable.new(nil).author_valid?(request.headers) # || Rails.env.test?
      # author_signed_in? && valid?(request.headers) || Rails.env.test?
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:access_id)
    end
end
