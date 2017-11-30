module SubmissionStates
  class CollectingFormatReviewFilesRejected < SubmissionState
    @name = 'collecting format review files rejected'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForFormatReviewResponse]
    end

    def status_date(submission)
      submission.format_review_rejected_at
    end
  end
end
