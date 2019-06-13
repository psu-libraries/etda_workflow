class SpecialCommitteeController < ApplicationController

  layout 'home'

  def main
    @token = params[:authentication_token]
  end

  def advance_to_reviews
    
  end
end
