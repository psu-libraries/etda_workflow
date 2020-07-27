class Author::ProgramInformationView
  def initialize(submission_record)
    @record = submission_record || nil
  end

  def new_program_information_partial
    'standard_program_information'
  end

  def edit_program_information_partial
    'standard_program_information'
  end
end
