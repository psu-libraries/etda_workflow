class Lionpath::LionpathChair
  def import(row)
    this_program = program(row)
    return if this_program.blank?

    pc = ProgramChair.find_by(program: this_program, campus: row['Campus'], role: "Department Head")
    if pc.present?
      pc.update(dept_head_attrs(row))

      unless row['ROLE'].blank?
        pic = ProgramChair.find_by(program: this_program, campus: row['Campus'], role: "Professor in Charge")
        if pic.present?
          pic.update(prof_in_charge_attrs(row))
        end
      end
      return
    end

    ProgramChair.create({ program: this_program, role: "Department Head" }.merge(dept_head_attrs(row)))
    unless row['ROLE'].blank?
      ProgramChair.create({ program: this_program, role: "Professor in Charge" }.merge(prof_in_charge_attrs(row)))
    end
  end

  private

  def dept_head_attrs(row)
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

  def prof_in_charge_attrs(row)
    {
      access_id: row['DGS/PIC Access ID'].downcase,
      first_name: row['DGS/PIC First Name'],
      last_name: row['DGS/PIC Last Name'],
      campus: row['Campus'],
      phone: row['DGS/PIC Phone'],
      email: row['DGS/PIC Univ Email'].downcase,
      lionpath_updated_at: DateTime.now
    }
  end

  def program(row)
    Program.find_by(code: row['Acad Plan'])
  end
end
