# frozen_string_literal: true

class AdminController < ApplicationController

  before_action :admin_auth

  layout 'admin'

  protected

  def admin_auth
    authenticate_admin! unless admin_signed_in?
    @admin = current_admin
  end

  def current_ability
    @current_ability ||= AdminAbility.new(@admin)
  end
end
