class Author::CommitteeFormView
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def update?
    @submission.committee_members.count.positive?
  end

  def form_title
    return new_committee_label unless update?
    update_committee_label
  end

  def committee_form_partial
    return 'standard_committee_form' unless @submission.using_lionpath?
    'lionpath_committee_form'
  end

  def link_text
    return new_committee_label unless update?
    update_committee_label
  end

  def update_committee_label
    return 'Update Committee Members' unless @submission.using_lionpath?
    'Refresh Committee'
  end

  def new_committee_label
    return 'Add Committee Members' unless @submission.using_lionpath?
    'Verify Committee'
  end
end
