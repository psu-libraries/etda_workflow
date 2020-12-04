namespace :lionpath_import do

  desc "Core Lionpath import imports Program Chairs, Student Plans,
        and Committee Members in that order"
  task core: :environment do
    return unless current_partner.graduate?

    start = Time.now
    Lionpath::LionpathCsvImporter.new.import
    finish = Time.now
    Rails.logger.info "Process complete in #{(finish - start).seconds}"
  end
end
