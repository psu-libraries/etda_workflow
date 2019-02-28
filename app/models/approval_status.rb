# frozen_string_literal: true

class ApprovalStatus
  attr_reader :current_submission

  WORKFLOW_STATUS =
      [
          'none',
          'pending',
          'approved',
          'rejected'
      ].freeze

  def initialize(submission)
    @current_submission = submission
  end

  def status
    none || approved || rejected || pending
  end

  private

  def none
    return 'none' if current_submission.committee_members.count == 0
  end

  def approved
    return 'approved' unless (current_submission.committee_members.collect { |m| m.status == 'approved' }).count(false) > 0 # <-- Configured
  end

  def rejected
    return 'rejected' if (current_submission.committee_members.collect { |m| m.status == 'rejected' }).count(true) > 0 # <-- This number will be configured
  end

  def pending
    return 'pending'
  end
end