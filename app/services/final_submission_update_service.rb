class FinalSubmissionUpdateService
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

  def respond_final_submission
    msg = ''
    status_giver = SubmissionStatusGiver.new(submission)
    status_giver.can_respond_to_final_submission?
    if update_actions.approved?
      @submission.update_attribute :final_submission_approved_at, Time.zone.now
      if current_partner.honors?
        status_giver.can_waiting_for_publication_release?
        status_giver.waiting_for_publication_release!
        UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
        WorkflowMailer.send_final_emails(@submission)
      else
        status_giver.can_waiting_for_committee_review?
        status_giver.waiting_for_committee_review!
        UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
        @submission.update_status_from_committee
        WorkflowMailer.send_final_submission_approved_email(@submission)
        @submission.committee_review_requests_init if @submission.status_behavior.waiting_for_committee_review?
      end
      msg = "The submission\'s final submission information was successfully approved."
    elsif update_actions.rejected?
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
      submission.has_agreed_to_publication_release = false
      submission.publication_release_terms_agreed_to_at = nil
      submission.has_agreed_to_terms = false
      submission.final_submission_rejected_at = Time.zone.now
      submission.save
      status_giver.collecting_final_submission_files_rejected!
      WorkflowMailer.send_final_submission_rejected_email(@submission)
      msg = "The submission\'s final submission information was successfully rejected and returned to the author for revision."
    elsif update_actions.send_to_hold?
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
      submission.placed_on_hold_at = DateTime.now
      submission.save
      status_giver.can_waiting_in_final_submission_on_hold?
      status_giver.waiting_in_final_submission_on_hold!
      msg = "The submission was successfully placed on hold."
    end
    if update_actions.record_updated?
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
      msg += " Final submission information was successfully edited by an administrator"
    end
    OutboundLionPathRecord.new(submission: submission).report_status_change if update_actions.approved? || update_actions.rejected?
    { msg: msg, redirect_path: Rails.application.routes.url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_submitted') }
    #  "/admin/#{submission.degree_type.slug}/final_submission_submitted" }
  end

  def respond_waiting_to_be_released
    status_giver = SubmissionStatusGiver.new(submission)
    if update_actions.record_updated?
      # Editing a submission that is waiting to be released for publication
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
      { msg: 'The submission was successfully updated.', redirect_path: Rails.application.routes.url_helpers.admin_edit_submission_path(submission.id.to_s) }
    elsif update_actions.rejected?
      # Move back to Waiting for final submission approval (final submission submitted)
      # No file path changes necessary here; submission not released yet; files are still in workflow
      status_giver.can_remove_from_waiting_to_be_released?
      status_giver.waiting_for_final_submission_response!
      # @submission.update_attribute :final_submission_rejected_at, Time.zone.now  #this causes it to go into final rejected - WAS ERROR
      # submission.update_attributes! final_submission_params
      submission.final_submission_approved_at = nil
      submission.final_submission_rejected_at = nil
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
      { msg: 'Submission was removed from waiting to be released', redirect_path: Rails.application.routes.url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_approved') }
    elsif update_actions.send_to_hold?
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
      submission.placed_on_hold_at = DateTime.now
      submission.save
      status_giver.can_waiting_in_final_submission_on_hold?
      status_giver.waiting_in_final_submission_on_hold!
      { msg: "The submission was successfully placed on hold.", redirect_path: Rails.application.routes.url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_on_hold') }
    elsif update_actions.remove_hold?
      UpdateSubmissionService.admin_update_submission(submission, current_remote_user, final_submission_params)
      submission.removed_hold_at = DateTime.now
      submission.save
      status_giver.can_waiting_for_publication_release?
      status_giver.waiting_for_publication_release!
      { msg: "The submission was successfully removed from its hold and is waiting to be released.", redirect_path: Rails.application.routes.url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_approved') }
    end
  end

  def respond_released_submission
    if update_actions.rejected?
      # Unpublish/unrelease this submission
      status_giver = SubmissionStatusGiver.new(submission)
      status_giver.can_unrelease_for_publication?
      submission_release_service = SubmissionReleaseService.new
      original_final_files = submission_release_service.final_files_for_submission(submission)
      file_verification_results = submission_release_service.file_verification(original_final_files)
      # return unless file_verification_results
      # status_giver.unreleased_for_publication!
      submission.update_attributes(released_for_publication_at: nil, released_metadata_at: nil, status: 'waiting for publication release')
      SubmissionReleaseService.new.unpublish(original_final_files) if file_verification_results[:valid]
      solr_result = UpdateSubmissionService.new.solr_delta_update(submission) # update the index after the paper has been unreleased
      result = { msg: final_unrelease_message(solr_result, file_verification_results, submission), redirect_path: Rails.application.routes.url_helpers.admin_edit_submission_path(submission.id.to_s) }
    end
    result
  end

  private

  def final_unrelease_message(solr_result, file_verification_results, submission)
    solr_error_msg = "Solr indexing error occurred when un-publishing submission for #{submission.author_first_name} #{submission.author_last_name}" if solr_result[:error]
    success_msg = "Submission for #{submission.author_first_name} #{submission.author_last_name} was successfully un-published."
    msg = solr_result[:error] ? solr_error_msg : success_msg
    file_error_message = "\nError occurred relocating file for submission id #{submission.id}.  Please contact an administrator:  "
    # the following loop prints full file path details.  After app is stable, consider removing this.
    # The same information is also printed in production.log
    unless file_verification_results[:valid]
      msg << file_error_message
      file_verification_results[:file_error_list].each do |error_msg|
        msg << error_msg
      end
    end
    msg
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
      committee_members_attributes: [:id, :committee_role_id, :name, :email, :status, :notes, :is_required, :is_voting, :federal_funding_used, :_destroy],
      format_review_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      final_submission_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      keywords_attributes: [:word, :id, :_destroy],
      invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy]
    )
  end
end
