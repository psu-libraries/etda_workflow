namespace :report do

  desc "Sends email identifying Open Access releases for the semester to UL Cataloging"
  task oa_release: :environment do
    return unless current_partner.graduate?

    start = Time.now
    Rails.logger.info "Sending Open Access Report to UL Cataloging..."
    oa_report_email = OpenAccessReportEmail.new
    oa_report_email.deliver
    finish = Time.now
    Rails.logger.info "Process complete in #{(finish - start).seconds}"
  end
end
