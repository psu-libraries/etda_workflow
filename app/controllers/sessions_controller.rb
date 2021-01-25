# frozen_string_literal: true

class SessionsController < ApplicationController
  def destroy
    session['user_role'] = nil
    session['current_user'] = nil
    session['user_name'] = nil
    cookies.delete("mod_auth_openidc_session")
    redirect_to '/'
  end

  def new
    redirect_to '/login'
  end
end
