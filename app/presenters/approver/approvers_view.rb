class Approver::ApproversView
  def initialize(submission)
    @submission = submission || nil
  end

  def tooltip_text
    if @submission.restricted?
      AccessLevel.display[2][:description]
    elsif @submission.restricted_to_institution?
      AccessLevel.display[1][:description]
    else
      AccessLevel.display[0][:description]
    end
  end

  def approved?
    committee_status = ApprovalStatus.new(@submission).status
    if @submission.head_of_program_is_approving?
      head_of_program_status = ApprovalStatus.new(@submission).head_of_program_status
      return true if head_of_program_status == 'approved' && committee_status == 'approved'
    elsif committee_status == 'approved'
      return true
    end
    false
  end
end
