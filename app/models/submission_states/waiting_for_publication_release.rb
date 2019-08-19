# frozen_string_literal: true

module SubmissionStates
  class WaitingForPublicationRelease < SubmissionState
    @name = 'waiting for publication release'

    def initialize
      @transitions_to = [SubmissionStates::ReleasedForPublication, SubmissionStates::ReleasedForPublicationMetadataOnly, SubmissionStates::WaitingForFinalSubmissionResponse] # SubmissionStates::CollectingFinalSubmissionFiles]
    end

    def status_date(submission)
      submission.head_of_program_review_accepted_at || submission.committee_review_accepted_at
    end
  end
end
