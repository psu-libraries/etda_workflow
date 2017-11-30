module SubmissionStates
  class CollectingCommittee < SubmissionState
    @name = 'collecting committee'

    def initialize
      @transitions_to = [SubmissionStates::CollectingFormatReviewFiles]
    end

    # #SubmissionStates::StateGenerator.state_for_name('collecting committee').status_date(Submission.last)
    def status_date(submission)
      submission.committee_provided_at
    end
  end
end
