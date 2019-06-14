class SpecialCommitteeController < ApplicationController
  before_action :authenticate_and_redirect

  layout 'home'

  def main
  end

  def advance_to_reviews
    committee_member_token = CommitteeMemberToken.find_by(authentication_token: params[:authentication_token])
    return redirect_to '/401' unless committee_member_token

    marry_via_token(committee_member_token)
    redirect_to approver_approver_reviews_path
  end

  private

  def marry_via_token(committee_member_token)
    committee_member = committee_member_token.committee_member
    approver = Approver.find_by(access_id: current_remote_user)
    approver.committee_members << committee_member
    approver.save!
    CommitteeMemberToken.find(committee_member_token.id).destroy
  end

  def authenticate_and_redirect
    return unless current_remote_user

    redirect_to approver_approver_reviews_path
  end
end
