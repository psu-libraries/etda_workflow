# frozen_string_literal: true

module SubmissionStates
  class WaitingInFinalSubmissionOnHold < SubmissionState
    @name = 'waiting in final submission on hold'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForPublicationRelease]
    end

    def status_date(submission)
      submission.placed_on_hold_at
    end
  end
end
