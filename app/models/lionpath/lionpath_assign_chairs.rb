class Lionpath::LionpathAssignChairs
  def call
    submissions.each do |sub|
      next if program_chair(sub).blank?

      if submission_chair(sub).present?
        update_based_on_semester(sub)
        next
      end
      sub.committee_members << chair_member(sub)
      sub.save!
    end
  end

  private

  def create_chair_attrs(chair_role, program_chair)
    {
      committee_role_id: chair_role.id,
      name: "#{program_chair.first_name} #{program_chair.last_name}",
      email: program_chair.email,
      access_id: program_chair.access_id,
      is_required: true,
      is_voting: false,
      lionpath_updated_at: DateTime.now
    }
  end

  def update_chair_attrs(program_chair)
    {
      name: "#{program_chair.first_name} #{program_chair.last_name}",
      email: program_chair.email,
      access_id: program_chair.access_id,
      lionpath_updated_at: DateTime.now
    }
  end

  def submissions
    Submission.where('submissions.year >= ? AND submissions.lionpath_updated_at IS NOT NULL', DateTime.now.year)
  end

  def degree_type(submission)
    submission.degree.degree_type
  end

  def chair_role(submission)
    CommitteeRole.find_by(is_program_head: true, degree_type: degree_type(submission))
  end

  def submission_chair(submission)
    submission.committee_members.find_by(committee_role_id: chair_role(submission).id)
  end

  def program_chair(submission)
    submission.program.program_chairs.find { |n| n.campus == submission.campus }
  end

  def chair_member(submission)
    CommitteeMember.create create_chair_attrs(chair_role(submission), program_chair(submission))
  end

  def update_based_on_semester(submission)
    sub_chair = submission_chair(submission)
    prg_chair = program_chair(submission)
    sub_year = submission.year
    sub_sem = submission.semester
    if spring_sem_condition(sub_year)
      sub_chair.update update_chair_attrs(prg_chair)
    elsif summer_sem_condition(sub_year, sub_sem)
      sub_chair.update update_chair_attrs(prg_chair)
    elsif fall_sem_condition(sub_year, sub_sem)
      sub_chair.update update_chair_attrs(prg_chair)
    elsif DateTime.now.year != sub_year
      sub_chair.update update_chair_attrs(prg_chair)
    end
  end

  def spring_sem_condition(submission_year)
    Semester.current == "#{submission_year} Spring"
  end

  def summer_sem_condition(submission_year, submission_semester)
    (Semester.current == "#{submission_year} Summer") && (submission_semester != 'Spring')
  end

  def fall_sem_condition(submission_year, submission_semester)
    (Semester.current == "#{submission_year} Fall") && (submission_semester == 'Fall')
  end
end
