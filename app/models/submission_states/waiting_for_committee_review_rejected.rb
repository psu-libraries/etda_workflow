# frozen_string_literal: true

module SubmissionStates
  class WaitingForCommitteeReviewRejected < SubmissionState
    @name = 'waiting for committee review rejected'

    def initialize
      @transitions_to = [SubmissionStates::CollectingFinalSubmissionFiles]
    end

    def status_date(submission)
      if current_partner.graduate?
        submission.committee_review_rejected_at if SubmissionStatus.new(submission).waiting_for_committee_review?
        submission.head_of_program_review_rejected_at if SubmissionStatus.new(submission).waiting_for_head_of_program_review?
      else
        submission.committee_review_rejected_at
      end
    end
  end
end
