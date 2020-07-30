class Lionpath::LionpathProgram
  def import(row)
    Submission.create author: author(row),
                      program: program(row),
                      degree: degree(row),
                      semester: semester(row),
                      year: year(row),
                      status: 'collecting program information'
  end

  private

  def year(row)
    case row['Exp Grad'].to_s[3]
    when 1
      return 'Spring'
    when 5
      return 'Summer'
    when 8
      return 'Fall'
    end
  end

  def semester(row)
    row['Exp Grad'].to_s[0..2].insert(1,'0').to_i
  end

  def author(row)
    author = Author.find_or_create_by(psu_idn: row['ID']) do |attrs|
      attrs.alternate_email_address = row['Alternate Email']
      attrs.first_name = row['First Name']
      attrs.last_name = row['Last Name']
    end
    return author if author.persisted?

    author.populate_with_ldap_attributes(author.psu_idn, 'psidn')
    author
  end

  def program(row)
    pg = Program.find_by code: row['Acadademic Plan']
    return pg if pg.present?

    Program.create name: row['Transcript Descr'].to_s,
                   code: row['Acadademic Plan'].to_s,
                   is_active: 0
  end

  def degree(row)
    incoming_dg = row['Acadademic Plan'].split('_')[1].to_s
    Degree.find_by(name: incoming_dg)
  end
end
