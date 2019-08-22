# frozen_string_literal: true

class Approver::ApproversController < ApproverController
  before_action :verify_approver, except: [:download_final_submission, :index, :special_committee_link]
  include ActionView::Helpers::UrlHelper

  def index
    @approver = Approver.find_by(access_id: current_approver.access_id)
    @committee_members = @approver.committee_members
  end

  def edit
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
    @review_complete = SubmissionStatus.new(@submission).beyond_waiting_for_head_of_program_review?
    @author = @submission.author
    @most_relevant_file_links = most_relevant_file_links
    @view = Approver::ApproversView.new(@submission)
  end

  def update
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
    if params[:committee_member][:status] == ""
      flash[:error] = 'Validation Failed: You must select whether you approve or reject before submitting your review.'
      return redirect_to(approver_path(params[:id]))
    end
    if (params[:committee_member][:federal_funding_used] == "") && @committee_member.committee_role.name.include?("Advisor")
      flash[:error] = 'Validation Failed: As an Advisor, you must indicate if federal funding was utilized for this submission.'
      return redirect_to(approver_path(params[:id]))
    end
    @committee_member.update_attributes!(committee_member_params)
    Approver.status_merge(@committee_member)
    @submission.update_status_from_committee
    redirect_to approver_root_path
    flash[:notice] = 'Review submitted successfully'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
    redirect_to approver_path(params[:id])
  end

  def verify_approver
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
    redirect_to '/404' if @approver.nil? || current_approver.nil?
    redirect_to '/401' unless @approver_ability.can?(:edit, @committee_member)
  end

  def download_final_submission
    file = FinalSubmissionFile.find(params[:id])
    if file.submission.committee_members.pluck(:access_id).include? current_approver.access_id
      send_file file.current_location, disposition: :inline
    else
      redirect_to '/401'
    end
  end

  def committee_reviews
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
  end

  def special_committee_link
    @committee_member_token = CommitteeMemberToken.find_by(authentication_token: params[:authentication_token])
    return redirect_to approver_approver_reviews_path unless @committee_member_token

    marry_via_token(@committee_member_token)
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

  def committee_member_params
    params.require(:committee_member).permit(:notes, :status, :federal_funding_used)
  end

  def most_relevant_file_links
    links = []
    if @submission.final_submission_files.any?
      @submission.final_submission_files.map do |f|
        link = link_to f.asset_identifier, approver_approver_file_path(f.id), 'target': '_blank', 'data-no-turbolink': true
        links.push(link)
      end
    end
    links.join(" ")
  end
end
