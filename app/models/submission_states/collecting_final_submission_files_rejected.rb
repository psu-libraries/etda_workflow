# frozen_string_literal: true

module SubmissionStates
  class CollectingFinalSubmissionFilesRejected < SubmissionState
    @name = 'collecting final submission files rejected'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForCommitteeReview, SubmissionStates::WaitingForFinalSubmissionResponse]
    end

    def status_date(submission)
      submission.final_submission_rejected_at
    end
  end
end
