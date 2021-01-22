# frozen_string_literal: true

class AuthorController < ApplicationController
  before_action :author_auth

  layout 'author'

  protected

  def author_auth
    authenticate_author! unless author_signed_in?
    @author = current_author
    author_ability
    session[:user_role] = 'author'
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
