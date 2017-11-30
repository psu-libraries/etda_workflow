module SubmissionStates
  class ConfidentialHoldEmbargo < SubmissionState
    @name = 'confidential hold embargo'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForFinalSubmissionResponse]
    end

    def status_date(submission)
      submission.confidential_hold_embargoed_at
    end
  end
end
