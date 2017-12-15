class AdminController < ApplicationController
  protect_from_forgery with: :exception

  Devise.add_module(:webacess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  before_action :clear_admin
  before_action :authenticate_or_redirect
  before_action :find_or_initialize_admin

  layout 'admin'

  protected

    def find_or_initialize_admin
      @admin = Admin.find_or_initialize_by(access_id: current_admin.access_id)
      # Rails.logger.info "current_admin = #{current_admin.inspect}"
      render 'admin/index'
    end

    def clear_admin
      # Rails.logger.info 'CLEARING ADMIN...........'
      # only logout if the REMOTE_USER is not set in the HTTP headers and a user is set within warden
      #  logout clears the entire session including flash messages
      request.env['warden'].logout if current_remote_user.nil? || !valid_admin_session?
    end

    def authenticate_or_redirect
      # Rails.logger.info "Authenticating Admin: #{current_remote_user}"
      if valid_admin?
        authenticate_admin! unless valid_admin_session?
      else
        redirect_to '/401' # unauthorized page
      end
    end

    def valid_admin?
      this_admin = current_remote_user
      user_is_admin = LdapUniversityDirectory.new.in_admin_group?(this_admin)
      session[:user_role] = 'admin' if user_is_admin
      user_is_admin
    end

    def valid_admin_session?
      session[:user_role] == 'admin'
    end
end
