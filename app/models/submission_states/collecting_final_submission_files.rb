# frozen_string_literal: true

module SubmissionStates
  class CollectingFinalSubmissionFiles < SubmissionState
    @name = 'collecting final submission files'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForCommitteeReview] if current_partner.honors?
      @transitions_to = [SubmissionStates::WaitingForFinalSubmissionResponse] unless current_partner.honors?
    end

    def status_date(submission)
      submission.format_review_approved_at
    end
  end
end
