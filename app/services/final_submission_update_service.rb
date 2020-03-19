class FinalSubmissionUpdateService
  include ActionView::Helpers::UrlHelper

  attr_accessor :params, :submission, :update_actions, :current_remote_user

  def initialize(params, submission, current_remote_user)
    @submission = submission
    @submission.author_edit = false
    @params = params
    @update_actions = SubmissionUpdateActions.new(params)
    @current_remote_user = current_remote_user
  end

  def update_record
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    { msg: "The submission was successfully updated.", redirect_path: admin_edit_sub_path }
  end

  def respond_final_submission
    msg = ''
    status_giver = SubmissionStatusGiver.new(submission)
    status_giver.can_respond_to_final_submission?
    action_service = FinalSubmissionSubmittedService.new(submission, current_remote_user,
                                                         status_giver, final_submission_params)
    lionpath_outbound = OutboundLionPathRecord.new(submission: submission)
    if update_actions.approved?
      msg = action_service.final_submission_approved
    elsif update_actions.rejected?
      msg = action_service.final_submission_rejected
    elsif update_actions.record_updated?
      msg += action_service.final_submission_updated
    end
    lionpath_outbound.report_status_change if update_actions.approved? || update_actions.rejected?
    { msg: msg, redirect_path: admin_submitted_sub_index_path }
  end

  def respond_waiting_to_be_released
    status_giver = SubmissionStatusGiver.new(submission)
    approved_service = FinalSubmissionApprovedService.new(submission, current_remote_user,
                                                          status_giver, final_submission_params)
    if update_actions.record_updated?
      approved_service.release_updated
    elsif update_actions.rejected?
      approved_service.release_rejected
    elsif update_actions.send_to_hold?
      approved_service.release_sent_to_hold
    elsif update_actions.remove_hold?
      approved_service.release_remove_hold
    end
  end

  def respond_released_submission
    return unless update_actions.rejected?

    status_giver = SubmissionStatusGiver.new(submission)
    status_giver.can_unrelease_for_publication?
    release_service = FinalSubmissionReleaseService.new(submission)
    release_service.released_unpublish
  end

  private

  def admin_submitted_sub_index_path
    url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_submitted')
  end

  def admin_edit_sub_path
    url_helpers.admin_edit_submission_path(submission.id.to_s)
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def final_submission_params
    params.require(:submission).permit(
      :semester,
      :year,
      :author_id,
      :program_id,
      :degree_id,
      :title,
      :allow_all_caps_in_title,
      :format_review_notes,
      :admin_notes,
      :final_submission_notes,
      :defended_at,
      :abstract,
      :access_level,
      :is_printed,
      :has_agreed_to_terms,
      :has_agreed_to_publication_release,
      :lion_path_degree_code,
      :restricted_notes,
      :federal_funding,
      committee_members_attributes: [:id, :committee_role_id, :name, :email, :status, :notes, :is_required,
                                     :is_voting, :federal_funding_used, :_destroy],
      format_review_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      final_submission_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      keywords_attributes: [:word, :id, :_destroy],
      invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy]
    )
  end
end
