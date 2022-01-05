class Admin::ReportsController < AdminController
  def custom_report_index
    @semester_list = Submission.order('author_submitted_year DESC')
                               .pluck(:author_submitted_year, :author_submitted_semester)
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
    @csv_report_export = ExportCsv.new('custom_report', Submission.where(id: ids))
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
    @csv_report_export = ExportCsv.new('final_submission_approved', Submission.where(id: ids))
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
    @csv_report_export = ExportCsv.new('confidential_hold_report', Author.where(id: ids))
    respond_to do |format|
      format.csv { render template: 'admin/reports/csv_export_report.csv.erb' }
      headers['Content-Disposition'] = 'attachment; filename="confidential_hold_report.csv"'
      headers['Content-Type'] ||= 'text/csv'
      headers['Content-Type'] ||= 'text/xls'
    end
  end
end
