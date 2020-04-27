# frozen_string_literal: true

class Approver::ApproversController < ApproverController
  before_action :verify_approver, except: [:download_final_submission, :index, :special_committee_link]
  include ActionView::Helpers::UrlHelper

  def index
    @approver = Approver.find_by(access_id: current_approver.access_id)
    update_approver_committee_members(@approver.access_id)
    @committee_members = @approver.committee_members.select { |n| n if n.submission.status_behavior.beyond_collecting_final_submission_files? } if current_partner.honors?
    @committee_members = @approver.committee_members.select { |n| n if n.submission.status_behavior.beyond_waiting_for_final_submission_response? } unless current_partner.honors?
  end

  def edit
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
    @review_complete = SubmissionStatus.new(@submission).beyond_waiting_for_head_of_program_review?
    @author = @submission.author
    @most_relevant_file_links = most_relevant_file_links
    @view = Approver::ApproversView.new(@submission)
    return if @committee_member.committee_role.name.include? 'Advisor'

    @submission.committee_members.each do |member|
      redirect_to approver_path(member) if (member.access_id == @committee_member.access_id) && (member.committee_role.name.include? 'Advisor')
    end
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
    flash[:error] = e.record.errors.values.join(" ")
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
    if file.submission.committee_members.pluck(:approver_id).include? current_approver.id
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
    update_approver_committee_members_on_marry(approver, committee_member)
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

  def update_approver_committee_members(approver_access_id)
    approver = Approver.find_by(access_id: approver_access_id)
    committee_members = CommitteeMember.where(access_id: approver.access_id, approver_id: nil)
    committee_members.each do |committee_member|
      approver.committee_members << committee_member if approver.access_id == committee_member.access_id
    end
    approver.save!
  end

  def update_approver_committee_members_on_marry(approver, initial_committee_member)
    committee_member_email = initial_committee_member.email
    committee_members = CommitteeMember.where(email: committee_member_email)
    committee_members.each do |committee_member|
      committee_member.update_attribute :access_id, approver.access_id
      approver.committee_members << committee_member
      committee_member.committee_member_token ? CommitteeMemberToken.find(committee_member.committee_member_token.id).destroy : next
    end
    approver.save!
  end
end
