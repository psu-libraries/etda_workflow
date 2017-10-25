module SubmissionStates
  class ReleasedForPublication < SubmissionState
    @name = 'released for publication'

    def initialize
      @transitions_to = [SubmissionStates::WaitingForPublicationRelease, SubmissionStates::ReleasedForPublicationMetadataOnly]
    end

    def status_date(submission)
      submission.released_for_publication_at
    end
  end
end
