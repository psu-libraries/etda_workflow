class Approver::ApproversView
  def initialize(submission)
    @submission = submission || nil
  end

  def tooltip_text
    if @submission.restricted?
      "Restricts the entire work for patent and/or proprietary purposes.  At the end of the two-year period, the status will automatically change to Open Access.  This work should not be duplicated, shared, or used for any reason other than this review."
    elsif @submission.restricted_to_institution?
      "Access restricted to individuals having a valid Penn State Access Account.  Allows restricted access of the entire work beginning immediately after degree conferral.  At the end of the two-year period, the status will automatically change to Open Access.  This work should not be duplicated, shared, or used for any reason other than this review."
    else
      "Allows free worldwide access to the entire work beginning immediately after degree conferral."
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
