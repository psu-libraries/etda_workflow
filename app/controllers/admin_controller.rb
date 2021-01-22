# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :admin_auth

  layout 'admin'

  protected

  def admin_auth
    authenticate_admin!
    @admin = current_admin
    current_ability
    session[:user_role] = 'admin'
    session[:user_name] = current_admin.access_id
  end

  def current_ability
    @current_ability ||= AdminAbility.new(@admin)
  end
end
