# frozen_string_literal: true

module SubmissionStates
  class ReleasedForPublicationMetadataOnly < SubmissionState
    @name = 'released for publication metadata only'

    def initialize
      @transitions_to = [SubmissionStates::ReleasedForPublication, SubmissionStates::WaitingForPublicationRelease]
    end

    def status_date(submission)
      submission.released_metadata_at
    end
  end
end
