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

  def semester(row)
    case row['Exp Grad'].to_s[3].to_i
    when 1
      'Spring'
    when 5
      'Summer'
    when 8
      'Fall'
    end
  end

  def year(row)
    row['Exp Grad'].to_s[0..2].insert(1, '0').to_i
  end

  def author(row)
    author = Author.find_or_create_by(psu_idn: row['ID'].to_s) do |attrs|
      attrs.alternate_email_address = row['Alternate Email']
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
                   is_active: false
  end

  def degree(row)
    incoming_dg = row['Acadademic Plan'].split('_')[1].to_s
    Degree.find_by(name: incoming_dg)
  end
end
