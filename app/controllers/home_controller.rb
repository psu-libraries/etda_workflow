class HomeController < ApplicationController
  def index
    render '/home/index', layout: 'home'
  end

  def admin?
    Admin.find_by(access_id: current_remote_user)&.administrator?
  end

  helper_method :admin?
end
