# frozen_string_literal: true

module SubmissionStates
  class WaitingForCommitteeReview < SubmissionState
    @name = 'waiting for committee review'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForHeadOfProgramReview, SubmissionStates::WaitingForCommitteeReviewRejected, SubmissionStates::WaitingForPublicationRelease]
    end

    def status_date(submission)
      submission.final_submission_approved_at
    end
  end
end
