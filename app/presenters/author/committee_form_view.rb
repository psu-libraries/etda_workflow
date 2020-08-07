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

  def link_text
    return new_committee_label unless update?

    update_committee_label
  end

  def update_committee_label
    'Update Committee Members'
  end

  def new_committee_label
    'Add Committee Members'
  end
end
