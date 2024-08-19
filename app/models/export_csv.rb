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
    when 'custom_report'
      column_list = [
        'Submission ID',
        'Last Name',
        'First Name',
        'PSU ID',
        'Title',
        'Degree',
        'Program',
        'Access Level',
        'Status',
        'Graduation Date',
        'Federal Funding?',
        'Advisor Name',
        'PSU Email',
        'Alternate Email',
        'Academic Program',
        'Degree Checkout Status',
        'Admin Notes'
      ]
      column_list.insert(12, 'Thesis Supervisor Name') if current_partner.honors?
    when 'confidential_hold_report'
      column_list = ['ID', 'Access ID', 'Last Name', 'First Name', 'PSU Email Address', 'Alternate Email Address', 'PSU ID', 'Confidential Hold Set At']
    when 'committee_member_report'
      column_list = ['First Name', 'Middle Name', 'Last Name', 'Access ID', 'Department', 'Program', 'Degree', 'Submissions']
    when 'graduate_data_report'
      column_list = ['access_id', 'alternate_email_address', 'committee_members']
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
      field_list = [r.author.access_id, r.cleaned_title, r.id, r.author.last_name, r.author.first_name, r.author.middle_name, r.program_name, CommitteeMember.advisor_name(r), r.current_access_level.label]
      field_list = [r.cleaned_title, r.id, r.author.last_name, r.author.first_name, r.author.middle_name, r.program_name, r.committee_members.map(&:name).join('; '), r.current_access_level.label] if current_partner.graduate?
    when 'custom_report'
      field_list = [
        r.id,
        r.author.last_name,
        r.author.first_name,
        r.author.psu_id,
        r.cleaned_title,
        r.degree_type.name,
        r.program_name,
        r.current_access_level.label,
        r.admin_status,
        r.preferred_semester_and_year,
        r.federal_funding_display,
        CommitteeMember.advisor_name(r),
        r.author.psu_email_address,
        r.author.alternate_email_address,
        r.academic_program,
        r.degree_checkout_status,
        r.admin_notes
      ]
      field_list.insert(12, CommitteeMember.thesis_supervisor_name(r)) if current_partner.honors?
    when 'confidential_hold_report'
      field_list = [r.id, r.access_id, r.last_name, r.first_name, r.psu_email_address, r.alternate_email_address, r.psu_idn, r.confidential_hold_set_at]
    when 'committee_member_report'
      field_list = [r.first_name, r.middle_name, r.last_name, r.webaccess_id, r.department, r.program, r.degree, r.submissions]
    when 'graduate_data_report'
      field_list = {
        access_id: r.access_id,
        alternate_email_address: r.alternate_email_address,
        committee_members: formatted_committee_members(r)
      }
    else
      field_list = nil
    end
    field_list
  end

  def as_json
    @records.map { |record| fields(record) }
  end

  private

    def formatted_committee_members(row)
      formatted_cm = []
      row.committee_members.each do |member|
        formatted_cm << {
          name: member.name,
          email: member.email,
          role: member.committee_role.name
        }
      end
      formatted_cm
    end
end
