class SpecialCommitteeController < ApplicationController
  def main
    @token = params[:authentication_token]
  end
end
