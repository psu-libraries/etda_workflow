# frozen_string_literal: true

class ApproverController < ApplicationController
  before_action :set_session
  before_action :approver_auth

  layout 'approver'

  protected

    def set_session
      if current_remote_user.nil?
        session[:return_to] = request.url
        redirect_to '/login'
      end
      session[:user_role] = 'approver'
    end

    def approver_auth
      authenticate_approver!
      @approver = current_approver
      approver_ability
      session[:user_name] = current_approver.access_id
    end

    def approver_ability
      @approver_ability ||= ApproverAbility.new(@approver, params[:id])
    end
end
