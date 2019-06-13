class SpecialCommitteeController < ApplicationController

  layout 'home'

  def main
    @token = params[:authentication_token]
  end

  def advance_to_reviews
    committee_member = CommitteeMemberToken.find_by(authentication_token: params[:authentication_token]).committee_member
    return redirect_to '401' unless committee_member

    approver = Approver.find_by(access_id: current_remote_user)
    approver.committee_members << committee_member
    approver.save!
    #TODO redirect to /reviews landing
    redirect_to approver_path(committee_member)
  end
end
