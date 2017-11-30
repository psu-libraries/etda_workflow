module SubmissionStates
  class CollectingFormatReviewFiles < SubmissionState
    @name = 'collecting format review files'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForFormatReviewResponse]
    end

    def status_date(submission)
      submission.committee_provided_at
    end
  end
end
