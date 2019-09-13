# frozen_string_literal: true

module SubmissionStates
  class WaitingForCommitteeReview < SubmissionState
    @name = 'waiting for committee review'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReviewRejected, SubmissionStates::WaitingForPublicationRelease] unless current_partner.honors?
      @transitions_to = [SubmissionStates::WaitingForCommitteeReviewRejected, SubmissionStates::WaitingForFinalSubmissionResponse] if current_partner.honors?
    end

    def status_date(submission)
      submission.final_submission_approved_at unless current_partner.honors?
      submission.final_submission_files_uploaded_at if current_partner.honors?
    end
  end
end
