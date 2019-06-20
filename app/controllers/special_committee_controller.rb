class SpecialCommitteeController < ApplicationController
  before_action :authenticate_and_redirect, only: :main

  layout 'home'

  def main
  end

  def advance_to_reviews
    committee_member_token = CommitteeMemberToken.find_by(authentication_token: params[:authentication_token])
    return redirect_to approver_approver_reviews_path unless committee_member_token

    marry_via_token(committee_member_token)
  end

  private

  def authenticate_and_redirect
    return unless current_remote_user

    committee_member_token = CommitteeMemberToken.find_by(authentication_token: params[:authentication_token])
    return redirect_to approver_approver_reviews_path unless committee_member_token

    marry_via_token(committee_member_token)
  end

  def marry_via_token(committee_member_token)
    committee_member = committee_member_token.committee_member
    approver = Approver.find_by(access_id: current_remote_user)
    approver.committee_members << committee_member
    approver.save!
    CommitteeMemberToken.find(committee_member_token.id).destroy
    redirect_to approver_approver_reviews_path
  rescue NoMethodError => e
    redirect_to special_committee_main_path
    flash[:alert] = 'Please create a OneID account and login first.  If you already have an account, you can login by clicking the button at the top right of the screen.'
  end
end
