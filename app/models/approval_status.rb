# frozen_string_literal: true

class ApprovalStatus
  attr_reader :current_submission, :voting_committee_members, :committee_members,
              :approval_configuration, :head_of_program

  # Note that 'pending' status and 'none' status are different
  # 'Pending' means that the submission is past the evaluation_threshold? and is not 'approved' or 'rejected'
  # 'None' means that the submission is not past the evaluation_threshold? and is not 'rejected'
  APPROVED_STATUS = 'approved'
  REJECTED_STATUS = 'rejected'
  PENDING_STATUS = 'pending'
  NONE_STATUS = 'none'

  def initialize(submission)
    @current_submission = submission
    @voting_committee_members = submission.voting_committee_members
    @committee_members = submission.committee_members
    @approval_configuration = submission.degree.degree_type.approval_configuration
    @head_of_program = CommitteeMember.program_head current_submission
  end

  def head_of_program_status
    return APPROVED_STATUS if !@current_submission.head_of_program_is_approving? || head_of_program.blank?

    head_of_program.status
  end

  def status
    return NONE_STATUS unless evaluation_threshold? || rejected

    none || approved || rejected || pending
  end

  def approved_with_non_voters?
    return false unless approved

    non_voting_members_present?
  end

  private

    def none
      NONE_STATUS if voting_committee_members.count.zero?
    end

    def approved
      APPROVED_STATUS unless (voting_committee_members.collect { |m| m.status == APPROVED_STATUS }).count(false) > rejections_permitted
    end

    def rejected
      REJECTED_STATUS if (voting_committee_members.collect { |m| m.status == REJECTED_STATUS }).count(true) > rejections_permitted
    end

    def pending
      PENDING_STATUS
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

    def non_voting_members_present?
      committee_members.any? { |m| !member_voted?(m) }
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
      committee_member.status == APPROVED_STATUS || committee_member.status == REJECTED_STATUS
    end
end
