# frozen_string_literal: true

module SubmissionStates
  class WaitingForCommitteeReviewRejected < SubmissionState
    @name = 'waiting for committee review rejected'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForFinalSubmissionResponse] unless current_partner.honors?
      @transitions_to = [SubmissionStates::WaitingForCommitteeReview] if current_partner.honors?
    end

    def status_date(submission)
      submission.head_of_program_review_rejected_at || submission.committee_review_rejected_at
    end
  end
end
