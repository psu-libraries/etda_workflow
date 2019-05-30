# frozen_string_literal: true

class Approver::ApproversController < ApproverController
  before_action :verify_approver, except: :download_final_submission
  include ActionView::Helpers::UrlHelper

  def edit
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
    @author = @submission.author
    @most_relevant_file_links = most_relevant_file_links
  end

  def update
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
    if params[:committee_member][:status] == ""
      flash[:error] = 'You must submit a status'
      return redirect_to(approver_path(params[:id]))
    end
    @committee_member.update_attributes!(committee_member_params)
    if current_partner.graduate?
      @submission.update_status_from_committee
      @submission.update_status_from_head_of_program if CommitteeMember.head_of_program(@submission.id).id == @committee_member.id
    else
      @submission.update_status_from_committee
    end
    redirect_to main_page_path
    flash[:notice] = 'Review submitted successfully'
  rescue ActiveRecord::RecordInvalid
    redirect_to approver_path(params[:id])
  end

  def verify_approver
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
    redirect_to '/404' if @approver.nil? || current_approver.nil?
    # TODO: redirect to page indicating review is complete, if beyond_waiting_for_committee_review
    redirect_to '/401' unless @approver_ability.can?(:edit, @committee_member) && @submission.status_behavior.waiting_for_committee_review?
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

  private

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
