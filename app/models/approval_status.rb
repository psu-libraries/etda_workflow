# frozen_string_literal: true

class ApprovalStatus
  attr_reader :current_submission, :voting_committee_members, :committee_members,
              :approval_configuration, :head_of_program

  WORKFLOW_STATUS =
    [
      'none',
      'pending',
      'approved',
      'rejected'
    ].freeze

  def initialize(submission)
    @current_submission = submission
    @voting_committee_members = submission.voting_committee_members
    @committee_members = submission.committee_members
    @approval_configuration = submission.degree.degree_type.approval_configuration
    @head_of_program = CommitteeMember.program_head current_submission
  end

  def head_of_program_status
    return 'approved' if head_of_program.blank?

    head_of_program.status
  end

  def status
    return 'none' unless all_have_voted?

    none || approved || rejected || pending
  end

  private

  def none
    'none' if voting_committee_members.count.zero?
  end

  def approved
    'approved' unless (voting_committee_members.collect { |m| m.status == 'approved' }).count(false) > rejections_permitted
  end

  def rejected
    'rejected' if (voting_committee_members.collect { |m| m.status == 'rejected' }).count(true) > rejections_permitted
  end

  def pending
    'pending'
  end

  def rejections_permitted
    if approval_configuration.use_percentage
      voting_committee_members.count - num_approved_required
    else
      approval_configuration.configuration_threshold
    end
  end

  def num_approved_required
    (voting_committee_members.count.to_f * (approval_configuration.configuration_threshold.to_f / 100)).round
  end

  def all_have_voted?
    committee_members.each do |member|
      next if member == head_of_program

      return false unless member.status == 'approved' || member.status == 'rejected'
    end
    true
  end
end
