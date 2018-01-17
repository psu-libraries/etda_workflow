# frozen_string_literal: true

module SubmissionStates
  class WaitingForFormatReviewResponse < SubmissionState
    @name = 'waiting for format review response'

    def initialize
      @transitions_to = [SubmissionStates::CollectingFinalSubmissionFiles, SubmissionStates::CollectingFormatReviewFilesRejected, SubmissionStates::CollectingFormatReviewFiles]
    end

    def status_date(submission)
      submission.format_review_files_uploaded_at
    end
  end
end
