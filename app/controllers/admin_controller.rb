# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :set_session
  before_action :admin_auth

  layout 'admin'

  protected

    def set_session
      if current_remote_user.nil?
        # Its important that the return_to is NOT stored if:
        # - The request method is not GET (non idempotent)
        # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an infinite redirect loop
        # - The request is an Ajax request as this can lead to very unexpected behaviour
        session[:return_to] = if request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
                                request.url
                              else
                                admin_root_path
                              end
        redirect_to '/login'
      end
      session[:user_role] = 'admin'
    end

    def admin_auth
      authenticate_admin!
      @admin = current_admin
      current_ability
      session[:user_name] = current_admin.access_id
    end

    def current_ability
      @current_ability ||= AdminAbility.new(@admin)
    end
end
