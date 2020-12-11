# frozen_string_literal: true

class SubmissionStatusGiver
  class AccessForbidden < StandardError; end
  class InvalidTransition < StandardError; end
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def can_update_program_information?
    validate_current_state! [SubmissionStates::CollectingProgramInformation, SubmissionStates::CollectingCommittee, SubmissionStates::CollectingFormatReviewFiles]
  end

  def can_provide_new_committee?
    raise AccessForbidden, 'You must complete your committee in LionPATH before moving to step two.' if @submission.degree_type.slug == 'dissertation'

    validate_current_state! [SubmissionStates::CollectingCommittee]
  end

  def can_update_committee?
    valid_states = [SubmissionStates::CollectingFormatReviewFiles, SubmissionStates::CollectingFormatReviewFilesRejected, SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected]
    valid_states << SubmissionStates::CollectingCommittee if @submission.degree_type.slug == 'dissertation'
    validate_current_state! valid_states
  end

  def can_upload_format_review_files?
    validate_current_state! [SubmissionStates::CollectingFormatReviewFiles, SubmissionStates::CollectingFormatReviewFiles, SubmissionStates::CollectingFormatReviewFilesRejected]
  end

  def can_review_program_information?
    validate_current_state! [SubmissionStates::CollectingFormatReviewFiles, SubmissionStates::WaitingForFormatReviewResponse, SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected, SubmissionStates::FormatReviewAccepted, SubmissionStates::WaitingForCommitteeReview, SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReviewRejected, SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingForPublicationRelease, SubmissionStates::WaitingInFinalSubmissionOnHold, SubmissionStates::ReleasedForPublication, SubmissionStates::CollectingFormatReviewFilesRejected]
  end

  def can_create_or_edit_committee?
    validate_current_state! [SubmissionStates::CollectingCommittee, SubmissionStates::CollectingFormatReviewFiles, SubmissionStates::CollectingFormatReviewFilesRejected,
                             SubmissionStates::WaitingForFormatReviewResponse, SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected, SubmissionStates::FormatReviewAccepted, SubmissionStates::WaitingForCommitteeReview, SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReviewRejected, SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingForPublicationRelease, SubmissionStates::ReleasedForPublication, SubmissionStates::CollectingFormatReviewFilesRejected, SubmissionStates::CollectingFinalSubmissionFilesRejected]
  end

  def can_review_committee?
    validate_current_state! [SubmissionStates::WaitingForFormatReviewResponse, SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected,
                             SubmissionStates::FormatReviewAccepted, SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingForPublicationRelease, SubmissionStates::WaitingInFinalSubmissionOnHold, SubmissionStates::ReleasedForPublication, SubmissionStates::CollectingFormatReviewFilesRejected, SubmissionStates::CollectingFinalSubmissionFilesRejected] # , submission.beyond_collecting_format_review_files?
  end

  def can_review_format_review_files?
    validate_current_state! [SubmissionStates::WaitingForFormatReviewResponse, SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected, SubmissionStates::CollectingFormatReviewFilesRejected, SubmissionStates::FormatReviewAccepted, SubmissionStates::WaitingForCommitteeReview, SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReviewRejected, SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingForPublicationRelease, SubmissionStates::WaitingInFinalSubmissionOnHold, SubmissionStates::ReleasedForPublication, SubmissionStates::CollectingFinalSubmissionFilesRejected]
  end

  def can_upload_final_submission_files?
    validate_current_state! [SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::FormatReviewAccepted, SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected, SubmissionStates::WaitingForCommitteeReviewRejected]
  end

  def can_review_final_submission_files?
    validate_current_state! [SubmissionStates::WaitingForCommitteeReview, SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReviewRejected, SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingForPublicationRelease, SubmissionStates::WaitingInFinalSubmissionOnHold, SubmissionStates::ReleasedForPublication]
  end

  def can_respond_to_format_review?
    validate_current_state! [SubmissionStates::WaitingForFormatReviewResponse]
  end

  def can_waiting_for_final_submission?
    current_partner.honors? ? (validate_current_state! [SubmissionStates::WaitingForCommitteeReview, SubmissionStates::CollectingFinalSubmissionFilesRejected]) : (validate_current_state! [SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected, SubmissionStates::WaitingForCommitteeReviewRejected])
  end

  def can_respond_to_final_submission?
    validate_current_state! [SubmissionStates::WaitingForFinalSubmissionResponse]
  end

  def can_waiting_for_committee_review?
    current_partner.honors? ? (validate_current_state! [SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected, SubmissionStates::WaitingForCommitteeReviewRejected]) : (validate_current_state! [SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingForFinalSubmissionResponse])
  end

  def can_waiting_for_head_of_program_review?
    validate_current_state! [SubmissionStates::WaitingForCommitteeReview]
  end

  def can_waiting_for_committee_review_rejected?
    submission.head_of_program_is_approving? ? (validate_current_state! [SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReview]) : (validate_current_state! [SubmissionStates::WaitingForCommitteeReview])
  end

  def can_waiting_for_publication_release?
    submission.head_of_program_is_approving? ? (validate_current_state! [SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingInFinalSubmissionOnHold]) : (validate_current_state! [SubmissionStates::WaitingForCommitteeReview, SubmissionStates::WaitingInFinalSubmissionOnHold]) unless current_partner.honors?
    validate_current_state! [SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingInFinalSubmissionOnHold] if current_partner.honors?
  end

  def can_waiting_in_final_submission_on_hold?
    validate_current_state! [SubmissionStates::WaitingForPublicationRelease]
  end

  def can_release_for_publication?
    validate_current_state! [SubmissionStates::WaitingForPublicationRelease, SubmissionStates::ReleasedForPublication, SubmissionStates::ReleasedForPublicationMetadataOnly]
  end

  def can_remove_from_waiting_to_be_released?
    validate_current_state! [SubmissionStates::WaitingForPublicationRelease]
  end

  def can_unrelease_for_publication?
    validate_current_state! [SubmissionStates::ReleasedForPublication, SubmissionStates::ReleasedForPublicationMetadataOnly]
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
  end

  def validate_current_state!(expected_states)
    state = SubmissionStates::StateGenerator.state_for_name(submission.status)

    raise AccessForbidden unless expected_states.include? state.class
  end
end
