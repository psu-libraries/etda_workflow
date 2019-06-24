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
end