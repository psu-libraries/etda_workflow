# frozen_string_literal: true

class ApproverController < ApplicationController
  before_action :set_session
  before_action :approver_auth

  layout 'approver'

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
                                approver_root_path
                              end
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
