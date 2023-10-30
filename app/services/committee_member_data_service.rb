class CommitteeMemberDataService
  def fetch_committee_member_data
    subquery = CommitteeMember
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

    original_committee_member_data = subquery.to_sql

    CommitteeMember
      .from(Arel.sql("(#{original_committee_member_data}) AS subquery"))
      .select('department, college, program, SUM(submissions) AS submissions')
      .group('department, college, program')
      .order('department, SUM(submissions) DESC')
  end
end
