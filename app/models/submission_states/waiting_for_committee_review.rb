# frozen_string_literal: true

module SubmissionStates
  class WaitingForCommitteeReview < SubmissionState
    @name = 'waiting for committee review'

    def initialize
      if current_partner.graduate?
        @transitions_to = [SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReviewRejected]
      else
        @transitions_to = [SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingForCommitteeReviewRejected]
      end
    end

    def status_date(submission)
      submission.final_submission_files_uploaded_at
    end
  end
end
