# frozen_string_literal: true

class ApprovalStatus
  attr_reader :current_submission, :voting_committee_members, :committee_members,
              :approval_configuration, :head_of_program

  # Note that 'pending' status and 'none' status are different
  # 'Pending' means that the submission is past the evaluation_threshold and is not 'approved' or 'rejected'
  # 'None' means that the submission is not past the evaluation_threshold and is not 'rejected'
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
    return 'approved' if !@current_submission.head_of_program_is_approving? || head_of_program.blank?

    head_of_program.status
  end

  def status
    return 'none' unless evaluation_threshold? || rejected

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
      (voting_committee_members.count.to_f * (approval_configuration.configuration_threshold.to_f / 100)).ceil
    end

    def evaluation_threshold?
      committee_members.each do |member|
        next if program_head?(member)

        next if graduate_advisor?(member)

        return false unless member_voted?(member) || beyond_seven_days?(member)
      end

      true
    end

    def beyond_seven_days?(committee_member)
      committee_member.approval_started_at.present? && (DateTime.now > (committee_member.approval_started_at + 7.days))
    end

    def program_head?(committee_member)
      @current_submission.head_of_program_is_approving? && committee_member == head_of_program
    end

    def graduate_advisor?(committee_member)
      current_partner.graduate? && committee_member == current_submission.advisor
    end

    def member_voted?(committee_member)
      committee_member.status == 'approved' || committee_member.status == 'rejected'
    end
end
