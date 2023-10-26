class CommitteeMemberDataService
  def fetch_committee_member_data
    CommitteeMember
      .joins(:faculty_member)
      .joins(submission: :program)
      .select("
        CASE
          WHEN LOWER(faculty_members.department) LIKE '%dean%' THEN 'Office Of The Dean'
          ELSE faculty_members.department
        END AS department,
        faculty_members.college AS college,
        SUBSTRING_INDEX(programs.name, ' (', 1) AS program,
        COUNT(committee_members.submission_id) AS submissions
      ")
      .where.not('faculty_members.department' => '')
      .where.not('faculty_members.college' => [nil, ''])
      .where.not('programs.name' => [nil, ''])
      .group('faculty_members.college, programs.name, faculty_members.department')
      .order('department, COUNT(committee_members.submission_id) DESC')
  end
end
