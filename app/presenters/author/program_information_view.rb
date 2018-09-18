class Author::ProgramInformationView
  def initialize(submission_record)
    @record = submission_record || nil
  end

  def new_program_information_partial
    return 'standard_program_information' unless InboundLionPathRecord.active?

    'lionpath_program_information'
  end

  def edit_program_information_partial
    return 'standard_program_information' unless @record.using_lionpath?

    'lionpath_program_information'
  end
end
