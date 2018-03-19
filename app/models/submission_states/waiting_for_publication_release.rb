# frozen_string_literal: true

module SubmissionStates
  class WaitingForPublicationRelease < SubmissionState
    @name = 'waiting for publication release'

    def initialize
      @transitions_to = [SubmissionStates::ReleasedForPublication, SubmissionStates::ReleasedForPublicationMetadataOnly, SubmissionStates::WaitingForFinalSubmissionResponse] # SubmissionStates::CollectingFinalSubmissionFiles]
    end

    def status_date(submission)
      submission.final_submission_approved_at
    end

    def remove_date(submission)
      submission.final_submission_rejected_at
    end
  end
end
