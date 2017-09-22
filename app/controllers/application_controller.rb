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
    redirect_login_url = 'http://psu.edu' unless author_logged_in?
    Rails.logger.info "REDIRECTING---" + "#{redirect_login_url}  #{Time.zone.now}"
    redirect_to redirect_login_url
  end

  protected

    def author_logged_in?
      author_signed_in? || Rails.env.test?
      # author_signed_in? && (valid?(request.headers) || Rails.env.test?)
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:access_id)
    end
end
