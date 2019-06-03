class CommitteeReviewUpdateService
  include ActionView::Helpers::UrlHelper

  attr_accessor :params
  attr_accessor :submission
  attr_accessor :update_actions
  attr_accessor :current_remote_user

  def initialize(params, submission, current_remote_user)
    @submission = submission
    @submission.author_edit = false
    @params = params
    @update_actions = SubmissionUpdateActions.new(params)
    @current_remote_user = current_remote_user
  end

  def update_record
    UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
    { msg: "The submission was successfully updated.", redirect_path: Rails.application.routes.url_helpers.admin_edit_submission_path(submission.id.to_s) }
  end

  def should_status_change
    submission_status = ApprovalStatus.new(@submission).status
    status_giver = SubmissionStatusGiver.new(@submission)
    if submission_status == 'approved'
      status_giver.can_waiting_for_final_submission?
      status_giver.waiting_for_final_submission_response!
    elsif submission_status == 'rejected'
      status_giver.can_waiting_for_committee_review_rejected?
      status_giver.waiting_for_committee_review_rejected!
    end
    # OutboundLionPathRecord.new(submission: submission).report_status_change if update_actions.approved? || update_actions.rejected?
    # { msg: msg, redirect_path: Rails.application.routes.url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_submitted') }
    #  "/admin/#{submission.degree_type.slug}/final_submission_submitted" }
  end
end
