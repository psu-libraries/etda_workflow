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
    if update_actions.approved?
      msg = action_service.final_submission_approved
    elsif update_actions.rejected?
      msg = action_service.final_submission_rejected
    elsif update_actions.record_updated?
      msg += action_service.final_submission_updated
    elsif update_actions.rejected_committee?
      msg += action_service.final_rejected_send_committee
    elsif update_actions.rejected_dept_head?
      msg += action_service.final_rejected_send_dept_head
    end
    { msg:, redirect_path: admin_submitted_sub_index_path }
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
      FinalSubmissionParams.call(params)
    end

    def federal_funding_details_params
      funding_params = params.fetch(:federal_funding_details, {}).permit(
        :training_support_funding,
        :training_support_acknowledged,
        :other_funding,
        :other_funding_acknowledged
      )
      current_partner.graduate? ? funding_params : {}
    end
end
