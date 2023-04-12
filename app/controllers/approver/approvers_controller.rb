# frozen_string_literal: true

class Approver::ApproversController < ApproverController
  before_action :verify_approver, except: [:download_final_submission, :index, :special_committee_link]
  include ActionView::Helpers::UrlHelper

  def index
    @approver = current_approver
    ApproversService.new(current_approver).update_committee_w_access_id
    @committee_members = @approver.committee_members.select do |n|
      n if n.approval_started_at.present? && n.submission.status_behavior.beyond_collecting_final_submission_files?
    end
  end

  def edit
    @committee_member = CommitteeMember.find(params[:id])
    @submission = @committee_member.submission
    @author = @submission.author
    @review_complete = SubmissionStatus.new(@submission).beyond_waiting_for_head_of_program_review?
    @most_relevant_file_links = most_relevant_file_links
    @view = Approver::ApproversView.new(@submission)
    return if @committee_member.committee_role.name.include? 'Advisor'

    @submission.committee_members.each do |member|
      redirect_to approver_path(member) if advisor?(member, @committee_member)
    end
  end

  def update
    @committee_member = CommitteeMember.find(params[:id])
    @submission = Submission.find(@committee_member.submission.id)
    @committee_member.update!(committee_member_params.merge(approver_controller: true))
    Approver.status_merge(@committee_member)
    SubmissionStatusUpdaterService.new(@submission).update_status_from_committee
    redirect_to approver_root_path
    flash[:notice] = 'Review submitted successfully'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.collect(&:message).join(" ")
    redirect_to approver_path(params[:id])
  end

  def download_final_submission
    file = FinalSubmissionFile.find(params[:id])
    if file.submission.committee_members.pluck(:approver_id).include? current_approver.id
      send_file file.current_location, disposition: :inline
    else
      redirect_to '/401'
    end
  end

  def special_committee_link
    @committee_member_token = CommitteeMemberToken.find_by(authentication_token: params[:authentication_token])
    return redirect_to approver_approver_reviews_path unless @committee_member_token

    ApproversService.new(current_approver).update_committee_w_token(@committee_member_token)
    redirect_to approver_approver_reviews_path
  end

  private

    def advisor?(c_member, original_c_member)
      (c_member.access_id == original_c_member.access_id) && (c_member.committee_role.name.include? 'Advisor')
    end

    def verify_approver
      @committee_member = CommitteeMember.find(params[:id])
      @submission = @committee_member.submission
      redirect_to '/404' if @approver.nil? || current_approver.nil?
      redirect_to '/401' unless @approver_ability.can?(:edit, @committee_member)
    end

    def committee_member_params
      params.require(:committee_member).permit(:notes, :status, :federal_funding_used, :approver_controller)
    end

    def most_relevant_file_links
      links = []
      if @submission.final_submission_files.any?
        @submission.final_submission_files.map do |f|
          link = link_to f.asset_identifier, approver_approver_file_path(f.id), 'target': '_blank', 'data-no-turbolink': true, rel: 'noopener'
          links.push(link)
        end
      end
      links.join(" ")
    end
end
