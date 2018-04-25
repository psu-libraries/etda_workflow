class FinalSubmissionUpdateService
  include ActionView::Helpers::UrlHelper

  attr_accessor :params
  attr_accessor :submission
  attr_accessor :update_actions

  def initialize(params, submission)
    @submission = submission
    @submission.author_edit = false
    @params = params
    @update_actions = SubmissionUpdateActions.new(params)
  end

  def update_record
    submission.update_attributes! final_submission_params
    UpdateSubmissionService.call(submission)
    msg = "The submission was successfully updated."
    { msg: msg, redirect_path: Rails.application.routes.url_helpers.admin_edit_submission_path(submission.id.to_s) }
  end

  def respond_final_submission
    msg = ''
    status_giver = SubmissionStatusGiver.new(submission)
    status_giver.can_respond_to_final_submission?
    if update_actions.approved?
      submission.update_attribute :final_submission_approved_at, Time.zone.now
      status_giver.waiting_for_publication_release!
      submission.update_attributes! final_submission_params
      deliver_final_emails
      msg = "The submission\'s final submission information was successfully approved."
    elsif update_actions.rejected?
      submission.update_attribute :final_submission_rejected_at, Time.zone.now
      status_giver.collecting_final_submission_files_rejected!
      submission.update_attributes! final_submission_params
      msg = "The submission\'s final submission information was successfully rejected and returned to the author for revision."
    end
    if update_actions.record_updated?
      submission.update_attributes! final_submission_params
      msg += " Final submission information was successfully edited by an administrator"
    end
    OutboundLionPathRecord.new(submission: submission).report_status_change if update_actions.approved? || update_actions.rejected?
    { msg: msg, redirect_path: Rails.application.routes.url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_submitted') }
    #  "/admin/#{submission.degree_type.slug}/final_submission_submitted" }
  end

  def respond_waiting_to_be_released
    if update_actions.record_updated?
      # Release for publication
      submission.update_attributes! final_submission_params
      UpdateSubmissionService.call(submission)
      { msg: 'The submission was successfully updated.', redirect_path: Rails.application.routes.url_helpers.admin_edit_submission_path(submission.id.to_s) }
    elsif update_actions.rejected?
      # Move back to Waiting for final submission approval (final submission submitted)
      # No file changes necessary here; still in workflow
      status_giver = SubmissionStatusGiver.new(submission)
      status_giver.can_remove_from_waiting_to_be_released?
      UpdateSubmissionService.call submission
      status_giver.waiting_for_final_submission_response!
      # @submission.update_attribute :final_submission_rejected_at, Time.zone.now  #this causes it to go into final rejected
      # submission.update_attributes! final_submission_params
      submission.final_submission_approved_at = nil
      submission.final_submission_rejected_at = nil
      submission.update_attributes! final_submission_params
      { msg: 'Submission was removed from waiting to be released', redirect_path: Rails.application.routes.url_helpers.admin_submissions_index_path(submission.degree_type.slug, 'final_submission_approved') }
    end
  end

  def respond_released_submission
    if update_actions.record_updated?
      submission.update_attributes!(final_submission_params)
      UpdateSubmissionService.call(submission)
      result = { msg: 'The submission was successfully updated.', redirect_path: Rails.application.routes.url_helpers.admin_edit_submission_path(submission.id.to_s) }
    elsif update_actions.rejected?
      status_giver = SubmissionStatusGiver.new(submission)
      status_giver.can_unrelease_for_publication?
      submission_release_service = SubmissionReleaseService.new
      original_final_files = submission_release_service.final_files_for_submission(submission)
      return result unless submission_release_service.file_verification_successful(original_final_files)
      submission.update_attributes!(released_for_publication_at: nil, released_metadata_at: nil)
      status_giver.unreleased_for_publication!
      submission.update_attributes! final_submission_params
      SubmissionReleaseService.new.unpublish(original_final_files)
      # SolrDataImportService.delta_import # update the index after the paper has been unreleased
      result = { msg: "Submission for #{submission.author_first_name} #{submission.author_last_name} was successfully un-published", redirect_path: Rails.application.routes.url_helpers.admin_edit_submission_path(submission.id.to_s) }
    end
    result
  end

  private

  def final_submission_params
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
      :admin_notes,
      :final_submission_notes,
      :defended_at,
      :abstract,
      :access_level,
      :is_printed,
      :has_agreed_to_terms,
      :lion_path_degree_code,
      :restricted_notes,
      committee_members_attributes: [:id, :committee_role_id, :name, :email, :is_required, :_destroy],
      format_review_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      final_submission_files_attributes: [:asset, :asset_cache, :id, :_destroy],
      keywords_attributes: [:word, :id, :_destroy],
      invention_disclosures_attributes: [:id, :submission_id, :id_number, :_destroy]
    )
  end

  def deliver_final_emails
    AuthorMailer.final_submission_approved(@submission, "#{current_partner.id}.partner.email.url").deliver_now
    AuthorMailer.pay_thesis_fee(@submission).deliver_now if current_partner.honors?
  end
end
