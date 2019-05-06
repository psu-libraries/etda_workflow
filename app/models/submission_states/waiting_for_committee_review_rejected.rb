# frozen_string_literal: true

module SubmissionStates
  class WaitingForCommitteeReviewRejected < SubmissionState
    @name = 'waiting for committee review rejected'

    def initialize
      @transitions_to = [SubmissionStates::CollectingFinalSubmissionFiles]
    end

    def status_date(submission)
      current_partner.graduate? ? submission.head_of_program_review_rejected_at : submission.committee_review_rejected_at
    end
  end
end
