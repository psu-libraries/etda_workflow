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
    if current_submission.committee_members.count == 0
      return 'none'
    end

    approved = 0
    rejected = 0

    current_submission.committee_members.each do |member|
      if member.status == 'approved'
        approved += 1
      end

      if member.status == 'rejected'
        rejected += 1
      end
    end

    if approved == current_submission.committee_members.count
      return 'approved'
    elsif rejected > 0
      return 'rejected'
    else
      return 'pending'
    end
  end
end