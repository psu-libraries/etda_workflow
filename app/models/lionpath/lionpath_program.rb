class Lionpath::LionpathProgram
  def import(row)
    return if year(row) < 2021

    author = author(row)
    degree = degree(row)
    if author.submissions.present?
      submission = author.submissions.find_by(degree_id: degree.id)

      if submission.present?
        submission.update submission_attrs(row)
        return
      end
    end
    Submission.create({ status: 'collecting program information', author: author }.merge(submission_attrs(row)))
  end

  private

  def submission_attrs(row)
    {
      program: program(row),
      degree: degree(row),
      semester: semester(row),
      year: year(row),
      campus: row['Campus'],
      lionpath_updated_at: DateTime.now
    }
  end

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
                   is_active: true,
                   lionpath_updated_at: DateTime.now
  end

  def degree(row)
    incoming_dg = row['Acadademic Plan'].split('_')[1].to_s
    Degree.find_by(name: incoming_dg)
  end
end
