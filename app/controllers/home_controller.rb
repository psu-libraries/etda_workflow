class HomeController < ApplicationController
  def index
    render '/home/index', layout: 'home'
  end

  def is_admin?
    Admin.find_by(access_id: current_remote_user)&.administrator?
  end

  helper_method :is_admin?
end