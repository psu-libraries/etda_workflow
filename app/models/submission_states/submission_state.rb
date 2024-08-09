# frozen_string_literal: true

module SubmissionStates
  class SubmissionState
    attr_reader :transitions_to

    # add a class level attr_reader for name
    class << self; attr_reader :name end
    @name = "Change ME!!!!"

    def initialize
      @transitions_to = []
    end

    def valid_state_change?(new_submission_state)
      transitions_to.include? new_submission_state
    end

    # Change the sumission to my state if the transition is valid
    # @returns true -
    def self.transition(submission)
      return true if submission.status == name # no transition necisary just return

      state = SubmissionStates::StateGenerator.state_for_name(submission.status)
      if state.valid_state_change? self
        submission.update! status: name
        # When state changes, update Lionpath for graduate only if candidate number is present
        # We don't want this constantly running during tests or during development, so it should
        # only run in production or if the LP_EXPORT_TEST variable is set
        if (Rails.env.production? || ENV['LP_EXPORT_TEST']) &&
           current_partner.graduate? && submission.candidate_number
          Lionpath::LionpathExport.perform_async(submission.id)
        end
      else
        false # no transition made
      end
    end

    def self.status_date(submission)
      SubmissionStates::StateGenerator.submission_status_date(submission.status)
    end
  end
end
