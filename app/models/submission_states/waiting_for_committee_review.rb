# frozen_string_literal: true

module SubmissionStates
  class WaitingForCommitteeReview < SubmissionState
    @name = 'waiting for committee review'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReviewRejected, SubmissionStates::WaitingForFinalSubmissionResponse]
    end

    def status_date(submission)
      submission.final_submission_files_uploaded_at
    end
  end
end
