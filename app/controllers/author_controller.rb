# frozen_string_literal: true

class AuthorController < ApplicationController
  before_action :set_session
  before_action :author_auth

  layout 'author'

  protected

    def set_session
      if current_remote_user.nil?
        session[:return_to] = request.url
        redirect_to '/login'
      end
      session[:user_role] = 'author'
    end

    def author_auth
      authenticate_author!
      @author = current_author
      author_ability
      session[:user_name] = current_author.full_name
    end

    def author_ability
      @author_ability ||= AuthorAbility.new(@author, nil, nil)
    end

    def update_confidential_hold
      update_service = ConfidentialHoldUpdateService.new(@author, 'login_controller')
      update_service.update
    end
end
