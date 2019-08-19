# frozen_string_literal: true

module SubmissionStates
  class WaitingForFinalSubmissionResponse < SubmissionState
    @name = 'waiting for final submission response'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForCommitteeReview, SubmissionStates::CollectingFinalSubmissionFilesRejected]
    end

    def status_date(submission)
      submission.final_submission_files_uploaded_at
    end
  end
end
