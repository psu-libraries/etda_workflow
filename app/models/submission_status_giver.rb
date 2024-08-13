# frozen_string_literal: true

class SubmissionStatusGiver
  class AccessForbidden < StandardError; end
  class InvalidTransition < StandardError; end
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def can_update_program_information?
    validate_current_state! [SubmissionStates::CollectingProgramInformation,
                             SubmissionStates::CollectingCommittee,
                             SubmissionStates::CollectingFormatReviewFiles]
  end

  def can_provide_new_committee?
    validate_current_state! [SubmissionStates::CollectingCommittee]
  end

  def can_update_committee?
    submission.degree_type.slug == 'dissertation' ?
        (validate_current_state! [SubmissionStates::CollectingFormatReviewFiles,
                                  SubmissionStates::CollectingFormatReviewFilesRejected,
                                  SubmissionStates::CollectingFinalSubmissionFiles,
                                  SubmissionStates::CollectingFinalSubmissionFilesRejected,
                                  SubmissionStates::CollectingCommittee]) :
        (validate_current_state! [SubmissionStates::CollectingFormatReviewFiles,
                                  SubmissionStates::CollectingFormatReviewFilesRejected,
                                  SubmissionStates::CollectingFinalSubmissionFiles,
                                  SubmissionStates::CollectingFinalSubmissionFilesRejected])
  end

  def can_upload_format_review_files?
    validate_current_state! [SubmissionStates::CollectingFormatReviewFiles,
                             SubmissionStates::CollectingFormatReviewFiles,
                             SubmissionStates::CollectingFormatReviewFilesRejected]
  end

  def can_review_program_information?
    validate_current_state! [SubmissionStates::CollectingFormatReviewFiles,
                             SubmissionStates::WaitingForFormatReviewResponse,
                             SubmissionStates::CollectingFinalSubmissionFiles,
                             SubmissionStates::CollectingFinalSubmissionFilesRejected,
                             SubmissionStates::FormatReviewAccepted,
                             SubmissionStates::WaitingForCommitteeReview,
                             SubmissionStates::WaitingForHeadOfProgramReview,
                             SubmissionStates::WaitingForCommitteeReviewRejected,
                             SubmissionStates::WaitingForFinalSubmissionResponse,
                             SubmissionStates::WaitingForPublicationRelease,
                             SubmissionStates::WaitingInFinalSubmissionOnHold,
                             SubmissionStates::ReleasedForPublication,
                             SubmissionStates::CollectingFormatReviewFilesRejected,
                             SubmissionStates::WaitingForAdvisorReview]
  end

  def can_create_or_edit_committee?
    validate_current_state! [SubmissionStates::CollectingCommittee,
                             SubmissionStates::CollectingFormatReviewFiles,
                             SubmissionStates::CollectingFormatReviewFilesRejected,
                             SubmissionStates::CollectingFinalSubmissionFiles,
                             SubmissionStates::CollectingFinalSubmissionFilesRejected]
  end

  def can_review_committee?
    validate_current_state! [SubmissionStates::WaitingForFormatReviewResponse,
                             SubmissionStates::FormatReviewAccepted,
                             SubmissionStates::WaitingForFinalSubmissionResponse,
                             SubmissionStates::WaitingForPublicationRelease,
                             SubmissionStates::WaitingInFinalSubmissionOnHold,
                             SubmissionStates::ReleasedForPublication,
                             SubmissionStates::CollectingFormatReviewFilesRejected,
                             SubmissionStates::CollectingFinalSubmissionFilesRejected,
                             SubmissionStates::WaitingForAdvisorReview,
                             SubmissionStates::WaitingForCommitteeReview,
                             SubmissionStates::WaitingForHeadOfProgramReview,
                             SubmissionStates::WaitingForCommitteeReviewRejected]
  end

  def can_review_format_review_files?
    validate_current_state! [SubmissionStates::WaitingForFormatReviewResponse,
                             SubmissionStates::CollectingFinalSubmissionFiles,
                             SubmissionStates::CollectingFinalSubmissionFilesRejected,
                             SubmissionStates::CollectingFormatReviewFilesRejected,
                             SubmissionStates::FormatReviewAccepted,
                             SubmissionStates::WaitingForCommitteeReview,
                             SubmissionStates::WaitingForHeadOfProgramReview,
                             SubmissionStates::WaitingForCommitteeReviewRejected,
                             SubmissionStates::WaitingForFinalSubmissionResponse,
                             SubmissionStates::WaitingForPublicationRelease,
                             SubmissionStates::WaitingInFinalSubmissionOnHold,
                             SubmissionStates::ReleasedForPublication,
                             SubmissionStates::CollectingFinalSubmissionFilesRejected,
                             SubmissionStates::WaitingForAdvisorReview]
  end

  def can_upload_final_submission_files?
    validate_current_state! [SubmissionStates::CollectingFinalSubmissionFiles,
                             SubmissionStates::FormatReviewAccepted,
                             SubmissionStates::CollectingFinalSubmissionFilesRejected,
                             SubmissionStates::WaitingForCommitteeReviewRejected]
  end

  def can_review_final_submission_files?
    validate_current_state! [SubmissionStates::WaitingForCommitteeReview,
                             SubmissionStates::WaitingForHeadOfProgramReview,
                             SubmissionStates::WaitingForCommitteeReviewRejected,
                             SubmissionStates::WaitingForFinalSubmissionResponse,
                             SubmissionStates::WaitingForPublicationRelease,
                             SubmissionStates::WaitingInFinalSubmissionOnHold,
                             SubmissionStates::ReleasedForPublication,
                             SubmissionStates::WaitingForAdvisorReview]
  end

  def can_respond_to_format_review?
    validate_current_state! [SubmissionStates::WaitingForFormatReviewResponse]
  end

  def can_waiting_for_final_submission_response?
    validate_current_state! [SubmissionStates::WaitingForCommitteeReview,
                             SubmissionStates::WaitingForHeadOfProgramReview,
                             SubmissionStates::CollectingFinalSubmissionFilesRejected]
  end

  def can_respond_to_final_submission?
    validate_current_state! [SubmissionStates::WaitingForFinalSubmissionResponse]
  end

  def can_waiting_for_advisor_review?
    validate_current_state! [SubmissionStates::CollectingFinalSubmissionFiles,
                             SubmissionStates::WaitingForFinalSubmissionResponse,
                             SubmissionStates::WaitingForCommitteeReviewRejected]
  end

  def can_waiting_for_committee_review?
    validate_current_state! [SubmissionStates::CollectingFinalSubmissionFiles,
                             SubmissionStates::WaitingForFinalSubmissionResponse,
                             SubmissionStates::WaitingForAdvisorReview,
                             SubmissionStates::WaitingForCommitteeReviewRejected]
  end

  def can_waiting_for_head_of_program_review?
    validate_current_state! [SubmissionStates::WaitingForCommitteeReview,
                            SubmissionStates::WaitingForFinalSubmissionResponse]
  end

  def can_committee_review_admin_response?
    validate_current_state! [SubmissionStates::WaitingForHeadOfProgramReview,
                             SubmissionStates::WaitingForCommitteeReview,
                             SubmissionStates::WaitingForAdvisorReview]
  end

  def can_waiting_for_committee_review_rejected?
    validate_current_state! [SubmissionStates::WaitingForHeadOfProgramReview,
                             SubmissionStates::WaitingForCommitteeReview,
                             SubmissionStates::WaitingForAdvisorReview]
  end

  def can_waiting_for_publication_release?
    validate_current_state! [SubmissionStates::WaitingForFinalSubmissionResponse,
                             SubmissionStates::WaitingInFinalSubmissionOnHold]
  end

  def can_waiting_in_final_submission_on_hold?
    validate_current_state! [SubmissionStates::WaitingForPublicationRelease]
  end

  def can_release_for_publication?
    validate_current_state! [SubmissionStates::WaitingForPublicationRelease,
                             SubmissionStates::ReleasedForPublication,
                             SubmissionStates::ReleasedForPublicationMetadataOnly]
  end

  def can_remove_from_waiting_to_be_released?
    validate_current_state! [SubmissionStates::WaitingForPublicationRelease]
  end

  def can_request_extension?
    validate_current_state! [SubmissionStates::ReleasedForPublicationMetadataOnly]
    raise SubmissionStatusGiver::AccessForbidden if (submission.released_for_publication_at - submission.released_metadata_at) >= 3.years
  end

  def can_unrelease_for_publication?
    validate_current_state! [SubmissionStates::ReleasedForPublication,
                             SubmissionStates::ReleasedForPublicationMetadataOnly]
  end

  def collecting_committee!
    transition_to SubmissionStates::CollectingCommittee
  end

  def collecting_format_review_files!
    transition_to SubmissionStates::CollectingFormatReviewFiles
  end

  def waiting_for_format_review_response!
    transition_to SubmissionStates::WaitingForFormatReviewResponse
  end

  def collecting_format_review_files_rejected!
    transition_to SubmissionStates::CollectingFormatReviewFilesRejected
  end

  def collecting_final_submission_files!
    transition_to SubmissionStates::CollectingFinalSubmissionFiles
  end

  def collecting_final_submission_files_rejected!
    transition_to SubmissionStates::CollectingFinalSubmissionFilesRejected
  end

  def waiting_for_final_submission_response!
    transition_to SubmissionStates::WaitingForFinalSubmissionResponse
  end

  def waiting_for_advisor_review!
    transition_to SubmissionStates::WaitingForAdvisorReview
  end

  def waiting_for_committee_review!
    transition_to SubmissionStates::WaitingForCommitteeReview
  end

  def waiting_for_head_of_program_review!
    transition_to SubmissionStates::WaitingForHeadOfProgramReview
  end

  def waiting_for_committee_review_rejected!
    transition_to SubmissionStates::WaitingForCommitteeReviewRejected
  end

  def waiting_for_publication_release!
    transition_to SubmissionStates::WaitingForPublicationRelease
  end

  def waiting_in_final_submission_on_hold!
    transition_to SubmissionStates::WaitingInFinalSubmissionOnHold
  end

  def remove_from_waiting_to_be_released!
    transition_to SubmissionStates::CollectingFinalSubmissionFiles
  end

  def released_for_publication!
    transition_to SubmissionStates::ReleasedForPublication
  end

  def released_for_publication_metadata_only!
    transition_to SubmissionStates::ReleasedForPublicationMetadataOnly
  end

  def unreleased_for_publication!
    transition_to SubmissionStates::WaitingForPublicationRelease
  end

  private

  def transition_to(new_state)
    raise InvalidTransition unless new_state.transition submission

    # When state changes, update Lionpath for graduate only if candidate number is present
    # We don't want this constantly running during tests or during development, so it should
    # only run in production or if the LP_EXPORT_TEST variable is set
    if (Rails.env.production? || ENV['LP_EXPORT_TEST'].present?) && 
      current_partner.graduate? && submission.candidate_number
      LionpathExportWorker.perform_async(submission.id)
    end
  end

  def validate_current_state!(expected_states)
    state = SubmissionStates::StateGenerator.state_for_name(submission.status)

    raise AccessForbidden unless expected_states.include? state.class
  end
end
