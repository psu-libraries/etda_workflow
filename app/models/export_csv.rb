class ExportCsv
  attr_accessor :query_type
  attr_reader :records

  def initialize(query_type, records)
    @query_type = query_type
    @records = records
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
      column_list.append('Invention Disclosure Number')
    when 'confidential_hold_report'
      column_list = ['ID', 'Last Name', 'First Name', 'Middle Name', 'Access ID', 'PSU Email Address', 'Alternate Email Address', 'PSU ID', 'Confidential Hold', 'Confidential Hold Set At']
    else
      column_list = nil
    end
    column_list
  end

  def fields(record)
    return nil if record.nil?

    r = record

    case query_type
    when 'final_submission_approved'
      field_list = [r.author.access_id, r.cleaned_title, r.id, r.author.last_name, r.author.first_name, r.author.middle_name, r.program_name, CommitteeMember.advisor_name(s), r.current_access_level.label]
      field_list = [r.cleaned_title, r.id, r.author.last_name, r.author.first_name, r.author.middle_name, r.program_name, r.committee_members.map(&:name).join('; '), r.current_access_level.label] if current_partner.graduate?
    when 'committee_report'
      field_list = [r.author.last_name, r.author.first_name, r.author.psu_email_address, r.author.alternate_email_address, r.id, r.cleaned_title, r.degree_type.name, r.program.name, r.semester_and_year, r.committee_members.map { |cm| "#{cm.committee_role.name}, #{cm.name}, #{cm.email}" }.join('; '), CommitteeMember.advisors(r).map { |cm| "#{cm.committee_role.name}, #{cm.name}, #{cm.email}" }.join('; ')]
    when 'custom_report'
      field_list = [r.author.last_name, r.author.first_name, r.id, r.cleaned_title, r.degree_type.name, r.current_access_level.label, r.semester_and_year, r.status]
      #      field_list.append(r.invention_disclosure.first.id_number) if current_partner.graduate? && !r.invention_disclosure.nil?
    when 'confidential_hold_report'
      field_list = [r.id, r.last_name, r.first_name, r.middle_name, r.access_id, r.psu_email_address, r.alternate_email_address, r.psu_idn, r.confidential_hold_set_at]
    else
      field_list = nil
    end
    field_list
  end
end
