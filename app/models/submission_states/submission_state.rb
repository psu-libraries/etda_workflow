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
        submission.update_attribute :status, name
      else
        false # no transition made
      end
    end

    def self.status_date(submission)
      SubmissionStates::StateGenerator.submission_status_date(submission.status)
    end
  end
end
