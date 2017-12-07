class AuthorController < ApplicationController
  protect_from_forgery with: :exception

  Devise.add_module(:webacess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  before_action :authenticate_author! # unless author_signed_in?
  before_action :find_or_initialize_author

  protected

    def find_or_initialize_author
      @author = Author.find_or_initialize_by(access_id: current_author.access_id)
      Rails.logger.info "current_author = #{current_author.inspect}"
      render 'author/index'
    end
end
