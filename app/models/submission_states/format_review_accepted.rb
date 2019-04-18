# frozen_string_literal: true

module SubmissionStates
  class FormatReviewAccepted < SubmissionState
    @name = 'format review accepted'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForCommitteeReview]
    end

    def status_date(submission)
      submission.format_review_approved_at
    end
  end
end
