class Admin::ReportsController < AdminController
  def custom_report_index
    @semester_list = Submission.order('year DESC')
                               .pluck(:year, :semester)
                               .uniq.map { |str| ["#{str[0]} #{str[1]}"] }
    @semester_list << Semester.current unless @semester_list.include? Semester.current
    if params[:format] == 'json'
      semester = params[:semester].split(' ')
      @submissions = Submission.joins(degree: :degree_type)
                               .where('degree_types.name = ?', params[:degree_type])
                               .select do |submission|
                                 submission.preferred_semester_and_year == "#{semester[1]} #{semester[0]}"
                               end
    end
    respond_to do |format|
      format.html
      format.json
    end
  end

  def custom_report_export
    ids = params[:submission_ids].split(',').map(&:to_i)
    @csv_report_export = ExportReport.new('custom_report', Submission.where(id: ids))
    respond_to do |format|
      format.csv { render template: 'admin/reports/csv_export_report.csv.erb' }
      headers['Content-Disposition'] = 'attachment; filename="custom_report.csv"'
      headers['Content-Type'] ||= 'text/csv'
      headers['Content-Type'] ||= 'text/xls'
    end
  end

  def final_submission_approved
    return if params[:submission_ids].nil?

    ids = params[:submission_ids].split(',').map(&:to_i)
    @csv_report_export = ExportReport.new('final_submission_approved', Submission.where(id: ids))
    respond_to do |format|
      format.csv { render template: 'admin/reports/csv_export_report.csv.erb' }
      headers['Content-Disposition'] = 'attachment; filename="final_submission_report.csv"'
      headers['Content-Type'] ||= 'text/csv'
      headers['Content-Type'] ||= 'text/xls'
    end
  end

  def confidential_hold_report_index
    @authors = Author.joins(:submissions).group('id').where(confidential_hold: 1)
    respond_to do |format|
      format.html
      format.json
    end
  end

  def confidential_hold_report_export
    ids = params[:author_ids].split(',').map(&:to_i)
    @csv_report_export = ExportReport.new('confidential_hold_report', Author.where(id: ids))
    respond_to do |format|
      format.csv { render template: 'admin/reports/csv_export_report.csv.erb' }
      headers['Content-Disposition'] = 'attachment; filename="confidential_hold_report.csv"'
      headers['Content-Type'] ||= 'text/csv'
      headers['Content-Type'] ||= 'text/xls'
    end
  end

  def committee_member_report_export
    result = CommitteeMember
             .joins(:faculty_member)
             .joins(:submission)
             .joins('INNER JOIN programs p ON submissions.program_id = p.id')
             .joins('INNER JOIN degrees d ON submissions.degree_id = d.id')
             .select('faculty_members.first_name, faculty_members.middle_name, faculty_members.last_name, faculty_members.webaccess_id, faculty_members.department, p.name as program, d.name as degree, COUNT(committee_members.submission_id) as submissions')
             .where.not('faculty_members.department' => '')
             .group('faculty_members.webaccess_id, faculty_members.department, p.name, d.name')
             .order('faculty_members.webaccess_id, COUNT(committee_members.submission_id) DESC, faculty_members.department')

    @csv_report_export = ExportReport.new('committee_member_report', result)
    respond_to do |format|
      format.csv { render template: 'admin/reports/csv_export_report.csv.erb' }
      headers['Content-Disposition'] = 'attachment; filename="committee_member_report.csv"'
      headers['Content-Type'] ||= 'text/csv'
      headers['Content-Type'] ||= 'text/xls'
    end
  end

  def graduate_data_report_export
    respond_to do |format|
      format.json do
        render json: graduate_data_result.to_json, content_type: 'application/json'
        headers['Content-Disposition'] = 'attachment; filename="graduate_data_report.json"'
      end
    end
  end

  private

    def graduate_data_result
      Submission
        .joins('INNER JOIN invention_disclosures i ON submissions.id = i.submission_id')
        .joins('INNER JOIN authors a ON submissions.author_id = a.id')
        .joins('INNER JOIN programs p ON submissions.program_id = p.id')
        .joins('INNER JOIN degrees d ON submissions.degree_id = d.id')
        .joins('INNER JOIN committee_members cm ON submissions.id = cm.submission_id')
        .joins('INNER JOIN committee_roles cr ON cm.committee_role_id = cr.id')
        .group('submissions.id', 'i.id_number').collect do |s|
        { "access_id" => s.author.access_id, "alternate_email_address" => s.author.alternate_email_address, "committee_members" => s.committee_members.collect do |cm|
                                                                                                                                     {
                                                                                                                                       "name" => cm.name, "email" => cm.email, "role" => cm.committee_role.name
                                                                                                                                     }
                                                                                                                                   end }
      end
    end
end
