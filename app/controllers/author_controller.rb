# frozen_string_literal: true

class AuthorController < ApplicationController
  before_action :set_session
  before_action :author_auth

  layout 'author'

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
                                author_root_path
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
