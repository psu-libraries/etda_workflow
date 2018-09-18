class Admin::ReportsController < AdminController
  def custom_report_index
    @submissions = Submission.all
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

  def committee_report_index
    @submissions = Submission.released_for_publication
    respond_to do |format|
      format.html
      format.json
    end
  end

  def committee_report_export
    ids = params[:submission_ids].split(',').map(&:to_i)
    @csv_report_export = ExportCsv.new('committee_report', Submission.where(id: ids))
    respond_to do |format|
      format.csv { render template: 'admin/reports/csv_export_report.csv.erb' }
      headers['Content-Disposition'] = 'attachment; filename="committee_report.csv"'
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
end
