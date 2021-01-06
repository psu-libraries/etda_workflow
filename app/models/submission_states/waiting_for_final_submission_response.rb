# frozen_string_literal: true

module SubmissionStates
  class WaitingForFinalSubmissionResponse < SubmissionState
    @name = 'waiting for final submission response'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForPublicationRelease,
                         SubmissionStates::CollectingFinalSubmissionFilesRejected]
    end

    def status_date(submission)
      submission.committee_review_accepted_at
    end
  end
end
