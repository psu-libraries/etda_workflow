class SpecialCommitteeController < ApplicationController

  layout 'home'

  def main
    @token = params[:authentication_token]
  end
end
