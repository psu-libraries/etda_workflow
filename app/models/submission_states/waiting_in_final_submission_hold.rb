# frozen_string_literal: true

module SubmissionStates
  class WaitingInFinalSubmissionHold < SubmissionState
    @name = 'waiting in final submission hold'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForPublicationRelease]
    end

    def status_date(submission)
      submission.placed_on_hold_at
    end
  end
end
