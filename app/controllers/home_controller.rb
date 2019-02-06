class HomeController < ApplicationController
  Devise.add_module(:webaccess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_url

  def index
    render '/home/index', layout: 'home'
  end

  def admin?
    Admin.find_by(access_id: current_remote_user)&.administrator?
  end

  helper_method :admin?
end
