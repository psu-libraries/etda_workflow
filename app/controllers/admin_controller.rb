# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :set_session
  before_action :admin_auth

  layout 'admin'

  protected

    def set_session
      sign_out if session[:user_role] != 'admin'
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
