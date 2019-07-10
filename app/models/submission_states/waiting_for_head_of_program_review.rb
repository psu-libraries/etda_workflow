# frozen_string_literal: true

module SubmissionStates
  class WaitingForHeadOfProgramReview < SubmissionState
    @name = 'waiting for head of program review'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForPublicationRelease, SubmissionStates::WaitingForCommitteeReviewRejected]
    end

    def status_date(submission)
      submission.committee_review_accepted_at
    end
  end
end
