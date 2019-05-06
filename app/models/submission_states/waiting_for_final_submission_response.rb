# frozen_string_literal: true

module SubmissionStates
  class WaitingForFinalSubmissionResponse < SubmissionState
    @name = 'waiting for final submission response'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForPublicationRelease, SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFinalSubmissionFilesRejected]
    end

    def status_date(submission)
      current_partner.graduate? ? submission.head_of_program_review_accepted_at : submission.committee_review_accepted_at
    end
  end
end
