class ExportCsv
  attr_accessor :query_type
  attr_reader :submissions

  def initialize(query_type, submissions)
    @query_type = query_type
    @submissions = submissions
  end

  def columns
    case query_type
    when 'final_submission_approved'
      column_list = ['Access Id', 'Title', 'Id', 'Last Name', 'First Name', 'Middle Name', 'Program Name', 'Thesis Supervisor', 'Access Level']
      column_list = ['Title', 'Id', 'Last Name', 'First Name', 'Middle Name', 'Program Name', 'Committee Members', 'Access Level'] if current_partner.graduate?
    when 'committee_report'
      column_list = ['Last Name', 'First Name', 'Email', 'Alternate Email', 'Id', 'Title', 'Degree', 'Program', 'Date', 'Committee Members', 'Advisor']
    when 'custom_report'
      column_list = ['Last Name', 'First Name', 'Id', 'Title', 'Degree', 'Access Level', 'Date', 'Status']
      column_list.append('Invention Disclosure Number') if current_partner.graduate?
    else
      column_list = nil
    end
    column_list
  end

  #
  def fields(submission)
    return nil if submission.nil?
    s = submission

    case query_type
    when 'final_submission_approved'
      field_list = [s.author.access_id, s.cleaned_title, s.id, s.author.last_name, s.author.first_name, s.author.middle_name,
                    s.program_name, CommitteeMember.advisor_name(s), s.access_level_display]
      field_list = [s.cleaned_title, s.id, s.author.last_name, s.author.first_name, s.author.middle_name, s.program_name, s.committee_members.map(&:name).join('; '), s.access_level_display] if current_partner.graduate?
    when 'committee_report'
      field_list = [s.author.last_name, s.author.first_name, s.author.psu_email_address, s.author.alternate_email_address, s.id, s.cleaned_title, s.degree_type.name, s.program.name, s.semester_and_year, s.committee_members.map { |cm| "#{cm.role}, #{cm.name}, #{cm.email}" }.join('; '), CommitteeMember.advisors(s).map { |cm| "#{cm.role}, #{cm.name}, #{cm.email}" }.join('; ')]
    when 'custom_report'
      field_list = [s.author.last_name, s.author.first_name, s.id, s.cleaned_title, s.degree_type.name, s.current_access_level[:label], s.semester_and_year, s.status]
      #      field_list.append(s.invention_disclosure.first.id_number) if current_partner.graduate? && !s.invention_disclosure.nil?
    else
      field_list = nil
    end
    field_list
  end
end
