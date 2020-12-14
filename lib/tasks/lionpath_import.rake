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

  desc "Import committee roles from LionPATH committee role configuration file"

  task :committee_roles, [:file_location] => :environment do |task, args|
    return unless current_partner.graduate?

    start = Time.now
    Lionpath::LionpathCommitteeRoles.new(args[:file_location]).import
    finish = Time.now
    Rails.logger.info "Process complete in #{(finish - start).seconds}"
  end

  desc "Import program codes from lionpath PE_SR_G_ETD_STDNT_PLAN_PRC files
        Note: The core importer does this in tandem with student plan import,
        so this task isn't necessary for core import"
  task :program_codes, [:file_location] => :environment do |task, args|
    return unless current_partner.graduate?

    `#{Rails.root}/bin/lionpath-program.sh`
    file_location = (args[:file_location].present? ? args[:file_location] : '/var/tmp_lionpath/lionpath.csv')
    csv_options = { headers: true, encoding: "ISO-8859-1:UTF-8", quote_char: '"', force_quotes: true }
    CSV.foreach(file_location, csv_options) do |row|
      program_name = row['Transcript Descr'].to_s.strip
      program = Program.find_by(name: program_name)
      if program.present?
        program.update! code: row['Acadademic Plan'].to_s
      else
        Program.create name: program_name,
                       code: row['Acadademic Plan'].to_s,
                       is_active: 0
      end
    end
  end
end
