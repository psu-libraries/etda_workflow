class Author::CommitteeFormView
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end

  def update?
    @submission.committee_members.count.positive?
  end

  def dissertation?
    submission.degree_type.slug == 'dissertation'
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
    if dissertation?
      'Committee Members'
    else
      'Update Committee Members'
    end
  end

  def new_committee_label
    if dissertation?
      'Committee Members'
    else
      'Add Committee Members'
    end
  end

  def add_member_label
    if dissertation?
      'Add Special Signatory'
    else
      'Add Committee Member'
    end
  end
end
