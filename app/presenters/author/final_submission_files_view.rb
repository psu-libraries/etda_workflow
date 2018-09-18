class Author::FinalSubmissionFilesView
  def initialize(submission_record)
    @record = submission_record || nil
  end

  def defended_at_date_partial
    return 'defended_at_date' unless InboundLionPathRecord.active?

    'defended_at_date_hidden_for_final_submissions'
  end

  def author_access_level_view
    return 'access_level_static' unless current_partner.graduate?

    'access_level_standard'
  end

  def disclosure_class
    return '' unless current_partner.graduate?
    return '' if @record.access_level.restricted?

    'hidden'
  end

  def selected_access_level
    return AccessLevel.OPEN_ACCESS.attributes if @record.access_level.empty?

    @record.current_access_level.label
  end

  def psu_only(label)
    label == AccessLevel.RESTRICTED_TO_INSTITUTION.attributes
  end
end
