class SpecialCommitteeController < ApplicationController
  before_action :auto_redirect, only: :main

  layout 'home'

  def main
  end

  def advance_to_reviews
    redirect_to approver_special_committee_link_path(params[:authentication_token])
  end

  private

    def auto_redirect
      return unless current_remote_user

      redirect_to approver_special_committee_link_path(params[:authentication_token])
    end
end
