module SubmissionStates
  class FormatReviewAccepted < SubmissionState
    @name = 'format review accepted'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForFinalSubmissionResponse]
    end

    def status_date(submission)
      submission.format_review_approved_at
    end
  end
end
