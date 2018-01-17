# frozen_string_literal: true

module SubmissionStates
  class CollectingProgramInformation < SubmissionState
    @name = 'collecting program information'

    def initialize
      @transitions_to = [SubmissionStates::CollectingCommittee]
    end

    def status_date(submission)
      return Time.zone.now.strftime("%Y-%m-%d %H:%M:%S") if submission.nil?
      submission.author.updated_at
    end
  end
end
