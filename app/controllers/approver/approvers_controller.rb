# frozen_string_literal: true

class Approver::ApproversController < ApproverController
  protect_from_forgery with: :exception

  def edit
    @submission = Submission.find(params[:submission_id])
    @committee_member = CommitteeMember.find(params[:id])
  end

end