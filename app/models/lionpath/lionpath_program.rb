class Lionpath::LionpathProgram
  def import(row)
    return if year(row) < 2021

    author = author(row)
    degree = degree(row)
    program = program(row)
    if author.submissions.present?

      if Semester.current == "2021 Spring"
        submissions = sp2021_subs(author)
        return if submissions.present?
      end

      submission = author.submissions.find_by(degree_id: degree.id, program:)

      if submission.present?
        submission_update(submission, row)
        return
      end
    end
    Submission.create({ status: 'collecting program information',
                        author:, program: }.merge(submission_attrs(row)))
  end

  private

    def submission_update(submission, row)
      if !submission.status_behavior.beyond_waiting_for_final_submission_response_rejected?
        submission.update submission_attrs(row)
      elsif row['ChkoutStat'] != submission.degree_checkout_status
        submission.update(degree_checkout_status: row['ChkoutStat'], lionpath_updated_at: DateTime.now)
      end
    end

    def submission_attrs(row)
      {
        degree: degree(row),
        lionpath_semester: semester(row),
        lionpath_year: year(row),
        campus: row['Campus'],
        lionpath_updated_at: DateTime.now,
        academic_program: row['Acad Prog'].gsub(/^GR/, ''),
        degree_checkout_status: row['ChkoutStat'],
        candidate_number: row['Can Nbr']
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
      author = Author.find_or_create_by(access_id: row['Campus ID'].to_s.downcase) do |attrs|
        attrs.alternate_email_address = row['Alternate Email']
        attrs.psu_email_address = "#{attrs.access_id}@psu.edu"
      end
      return author if author.persisted?

      author.populate_with_ldap_attributes(author.access_id, 'uid')
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
      incoming_dg = row['Degree'].to_s.upcase.gsub('_', ' ')
      Degree.where('upper(name) = ?', incoming_dg).first
    end

    def sp2021_subs(author)
      author.submissions
            .where("submissions.year = 2021 AND submissions.semester = 'Spring' AND submissions.lionpath_updated_at IS NULL")
    end
end
