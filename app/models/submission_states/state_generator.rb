# frozen_string_literal: true

module SubmissionStates
  class StateGenerator
    @class_cache = {
      ReleasedForPublication.name => ReleasedForPublication.new,
      ReleasedForPublicationMetadataOnly.name => ReleasedForPublicationMetadataOnly.new,
      WaitingInFinalSubmissionOnHold.name => WaitingInFinalSubmissionOnHold.new,
      WaitingForPublicationRelease.name => WaitingForPublicationRelease.new,
      WaitingForFinalSubmissionResponse.name => WaitingForFinalSubmissionResponse.new,
      WaitingForAdvisorReview.name => WaitingForAdvisorReview.new,
      WaitingForCommitteeReview.name => WaitingForCommitteeReview.new,
      WaitingForHeadOfProgramReview.name => WaitingForHeadOfProgramReview.new,
      WaitingForCommitteeReviewRejected.name => WaitingForCommitteeReviewRejected.new,
      CollectingFinalSubmissionFiles.name => CollectingFinalSubmissionFiles.new,
      CollectingFinalSubmissionFilesRejected.name => CollectingFinalSubmissionFilesRejected.new,
      WaitingForFormatReviewResponse.name => WaitingForFormatReviewResponse.new,
      CollectingFormatReviewFiles.name => CollectingFormatReviewFiles.new,
      CollectingFormatReviewFilesRejected.name => CollectingFormatReviewFilesRejected.new,
      CollectingCommittee.name => CollectingCommittee.new,
      CollectingProgramInformation.name => CollectingProgramInformation.new,
      FormatReviewAccepted.name => FormatReviewAccepted.new
    }

    def self.state_for_name(state_name)
      @class_cache.fetch(state_name, Bogus.new)
    end
  end
end
