namespace :report do

  desc "Sends email identifying Open Access releases for the semester to UL Cataloging"
  task oa_release: :environment do
    return unless current_partner.graduate?

    start = Time.now
    Rails.logger.info "Sending Open Access Report to UL Cataloging..."
    begin
      oa_report_email = OpenAccessReportEmail.new
      oa_report_email.deliver
    rescue OpenAccessReportEmail::InvalidReleaseMonth
      Rails.logger.error "Invalid release month.  Reports only go out at the end of June, September, and January."
    end
    finish = Time.now
    Rails.logger.info "Process complete in #{(finish - start).seconds}"
  end
end
