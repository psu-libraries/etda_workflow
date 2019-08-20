# frozen_string_literal: true

module SubmissionStates
  class WaitingForFinalSubmissionResponse < SubmissionState
    @name = 'waiting for final submission response'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForCommitteeReview, SubmissionStates::CollectingFinalSubmissionFilesRejected] unless current_partner.honors?
      @transitions_to = [SubmissionStates::WaitingForPublicationRelease] if current_partner.honors?
    end

    def status_date(submission)
      submission.final_submission_files_uploaded_at unless current_partner.honors?
      submission.committee_review_accepted_at if current_partner.honors?
    end
  end
end
