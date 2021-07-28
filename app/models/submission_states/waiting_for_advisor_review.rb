module SubmissionStates
  class WaitingForAdvisorReview < SubmissionState
    @name = 'waiting for advisor review'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForCommitteeReview,
                         SubmissionStates::WaitingForCommitteeReviewRejected]
    end

    def status_date(submission)
      submission.final_submission_files_uploaded_at
    end
  end
end
