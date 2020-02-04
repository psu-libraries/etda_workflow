# frozen_string_literal: true

module SubmissionStates
  class WaitingForPublicationRelease < SubmissionState
    @name = 'waiting for publication release'

    def initialize
      @transitions_to = [SubmissionStates::ReleasedForPublication, SubmissionStates::ReleasedForPublicationMetadataOnly, SubmissionStates::WaitingForFinalSubmissionResponse, SubmissionStates::WaitingInFinalSubmissionOnHold]
    end

    def status_date(submission)
      if current_partner.honors?
        submission.final_submission_approved_at
      else
        submission.head_of_program_review_accepted_at || submission.committee_review_accepted_at
      end
    end
  end
end
