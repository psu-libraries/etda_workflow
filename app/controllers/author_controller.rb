# frozen_string_literal: true

class AuthorController < ApplicationController
  before_action :set_session
  before_action :author_auth

  layout 'author'

  protected

    def set_session
      if current_remote_user.nil?
        if request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
          session[:return_to] = request.url
        else
          session[:return_to] = author_root_path
        end
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
end
