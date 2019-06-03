class FormatReviewUpdateService
  include ActionView::Helpers::UrlHelper

  attr_accessor :params
  attr_accessor :submission
  attr_accessor :submission_type
  attr_accessor :update_actions
  attr_accessor :current_remote_user

  def initialize(params, submission, current_remote_user)
    @params = params
    @submission = submission
    @submission.author_edit = false
    @update_actions = SubmissionUpdateActions.new(params)
    @current_remote_user = current_remote_user
  end

  def update_record
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, format_review_params)
    msg = "The submission was successfully updated."
    { msg: msg, redirect_path: Rails.application.routes.url_helpers.admin_edit_submission_path(submission.id.to_s) }
  end

  def respond_format_review
    status_giver = SubmissionStatusGiver.new(@submission)
    status_giver.can_respond_to_format_review?
    msg = ''
    if update_actions.approved?
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, format_review_params)
      submission.update_attribute :format_review_approved_at, Time.zone.now
      status_giver.collecting_final_submission_files!
      msg = "The submission\'s format review information was successfully approved and returned to the author to collect final submission information."
    elsif update_actions.rejected?
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, format_review_params)
      submission.update_attribute :format_review_rejected_at, Time.zone.now
      status_giver.collecting_format_review_files_rejected!
      msg = "The submission\'s format review information was successfully rejected and returned to the author for revision."
    end
    if update_actions.record_updated?
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, format_review_params)
      msg += " Format review information was successfully edited by an administrator"
    end
    OutboundLionPathRecord.new(submission: submission).report_status_change if update_actions.approved? || update_actions.rejected?
    { msg: msg, redirect_path: "/admin/#{submission.degree_type.slug}/format_review_submitted" }
  end

  private

    def format_review_params
      params.require(:submission).permit(
        :semester,
        :year,
        :author_id,
        :program_id,
        :degree_id,
        :title,
        :defended_at,
        :allow_all_caps_in_title,
        :format_review_notes,
        :access_level,
        :admin_notes,
        :is_printed,
        :lion_path_degree_code,
        committee_members_attributes: [:id, :committee_role_id, :name, :email, :status, :notes, :is_required, :is_voting, :_destroy],
        format_review_files_attributes: [:asset, :asset_cache, :id, :_destroy]
      )
    end
end
