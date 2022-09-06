namespace :report do

  desc "Sends email identifying releases for the semester to UL Cataloging"
  task semester_release: :environment do
    abort 'Partner is not Graduate' unless current_partner.graduate?

    start = Time.now
    Rails.logger.info "Sending Semester Report to UL Cataloging..."
    oa_report_email = SemesterReleaseReportEmail.new
    oa_report_email.deliver
    finish = Time.now
    Rails.logger.info "Process complete in #{(finish - start).seconds}"
  end
end
