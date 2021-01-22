# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  Devise.add_module(:webaccess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_url

  rescue_from ActionController::RoutingError, with: :route_not_found
  unless Rails.env.test?
    # rescue_from Blacklight::Exceptions::InvalidSolrID, with: :render_404
    rescue_from ActionView::MissingTemplate, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::MissingFile, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from CanCan::AccessDenied, with: :render_401
    rescue_from ActionView::Template::Error, with: :render_500
    rescue_from ActiveRecord::StatementInvalid, with: :render_500
    rescue_from Mysql2::Error, with: :render_500
    rescue_from Net::LDAP::LdapError, with: :render_500
    rescue_from Redis::CannotConnectError, with: :render_500
    rescue_from Errno::ECONNREFUSED, with: :render_500
    rescue_from ActionDispatch::Cookies::CookieOverflow, with: :render_500
    rescue_from RuntimeError, with: :render_500
    rescue_from RestClient::Unauthorized, RestClient::Forbidden, with: :render_401
    rescue_from Author::NotAuthorizedToEdit, with: :render_401
    rescue_from RestClient::ExceptionWithResponse, with: :render_500
  end

  helper_method :admin?
  helper_method :explore_url

  def main
    render '/main/index.html', layout: 'home'
  end

  def about
    render '/about/index.html', layout: 'home'
  end

  def docs
    render '/docs/index.html', layout: 'home'
  end

  def login
    Rails.logger.info 'LOGGING IN APP CONTROLLER'
    # '/login' is to be protected at the webserver level
    redirect_to session['return_to'] || '/'
  end

  def logout
    reset_session
    cookies.delete("mod_auth_openidc_session")
    redirect_to session['return_to'] || '/'
  end

  def autocomplete
    results = LdapUniversityDirectory.new.autocomplete(params[:term])
    render json: results
  end

  def current_remote_user
    Devise::Strategies::WebaccessAuthenticatable.new(nil).remote_user(request.headers)
  end

  def render_404(exception)
    logger.error("Rendering 404 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/404', layout: "error", formats: %i[html json], status: :not_found
  end

  def render_500(exception)
    logger.error("Rendering 500 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/500', layout: "error", formats: %i[html json], status: :internal_server_error
  end

  def render_401(exception)
    logger.error("Rendering 401 page due to exception #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/401', layout: "error", formats: %i[html json], status: :unauthorized
  end

  def admin?
    Admin.find_by(access_id: current_remote_user)&.administrator?
  end

  def explore_url
    EtdUrls.new.explore
  end

  protected

  def set_url
    ApplicationUrl.current = request.original_url
    ApplicationUrl.stage
  end

  def webaccess_login_url
    WebAccess.new.login_url
  end

  def webaccess_logout_url
    WebAccess.new.logout_url
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:access_id)
  end
end
