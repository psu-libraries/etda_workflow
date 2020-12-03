class Lionpath::LionpathChair
  def import(row)
    this_program = program(row)
    return if this_program.blank?

    pc = ProgramChair.find_by(program: this_program, campus: row['Campus'])
    return pc.update(chair_attrs(row)) if pc.present?

    ProgramChair.create({ program: this_program }.merge(chair_attrs(row)))
  end

  private

  def chair_attrs(row)
    {
      access_id: row['Access ID'].downcase,
      first_name: row['First Name'],
      last_name: row['Last Name'],
      campus: row['Campus'],
      phone: row['Phone'],
      email: row['Univ Email'].downcase,
      lionpath_updated_at: DateTime.now
    }
  end

  def program(row)
    Program.find_by(code: row['Acad Plan'])
  end
end
