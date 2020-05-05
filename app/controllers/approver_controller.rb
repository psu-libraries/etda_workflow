# frozen_string_literal: true

class ApproverController < ApplicationController
  protect_from_forgery with: :exception

  Devise.add_module(:webaccess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  before_action :clear_approver
  before_action :find_or_initialize_approver
  before_action :authenticate_or_redirect

  layout 'approver'

  protected

  def find_or_initialize_approver
    @approver = Approver.find_or_initialize_by(access_id: current_approver.access_id)
    session[:user_name] = @approver.access_id
    approver_ability
    # Rails.logger.info "current_approver = #{current_approver.inspect}"
    # redirect to login_path if @approver.nil?
  end

  def clear_approver
    # Rails.logger.info 'CLEARING APPROVER...........'
    # only logout if the REMOTE_USER is not set in the HTTP headers and a user is set within warden
    #  logout clears the entire session including flash messages
    request.env['warden'].logout if current_remote_user.nil? || !valid_approver_session?
  end

  def authenticate_or_redirect
    return if valid_approver_session?

    if valid_approver?
      authenticate_approver!
    else
      redirect_to '/401'
    end
  end

  def valid_approver?
    return false unless current_remote_user.present?

    session[:user_role] = 'approver'
    true
  end

  def valid_approver_session?
    return false if session[:user_role] != 'approver'

    current_user_check
  end

  def current_user_check
    current_remote_user == current_approver.access_id
  end

  def approver_ability
    @approver_ability ||= ApproverAbility.new(current_approver, params[:id])
  end
end
