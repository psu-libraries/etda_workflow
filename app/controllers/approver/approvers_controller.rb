# frozen_string_literal: true

class Approver::ApproversController < ApproverController
  before_action :verify_approver

  def edit
    @committee_member = CommitteeMember.find(params[:id])
  end

  def verify_approver
    @committee_member = CommitteeMember.find(params[:id])
    redirect_to '/404' if @approver.nil? || current_approver.nil?
    redirect_to '/401' unless @approver_ability.can? :edit, @committee_member
  end

end