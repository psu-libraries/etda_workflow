require 'net/sftp'

class Lionpath::LionpathCsvImporter
  class InvalidResource < StandardError; end
  class InvalidPartner < StandardError; end

  # Order is essential here; Do not change.
  LIONPATH_RESOURCES = [
    Lionpath::LionpathCommitteeRoles.new,
    Lionpath::LionpathProgram.new,
    Lionpath::LionpathCommittee.new
  ].freeze

  # Patterns sftp will look for when pulling csv file
  LIONPATH_FILE_PATTERNS = {
    committee_role: 'PE_SR_G_ETD_ACT_COMROLES',
    program: 'PE_SR_G_ETD_STDNT_PLAN_PRC',
    committee: 'PE_SR_G_ETD_COMMITTEE_PRC'
  }.freeze

  def import
    raise InvalidPartner unless current_partner.graduate?

    LIONPATH_RESOURCES.each do |resource|
      File.delete(lionpath_csv_loc) if File.exist?(lionpath_csv_loc)
      grab_file(resource)
      parse_csv(resource)
      File.delete(lionpath_csv_loc) if File.exist?(lionpath_csv_loc)
    end
    Lionpath::LionpathDeleteExpiredRecords.delete
  end

  def sftp_download(_pattern)
    sftp = Net::SFTP.start(ENV['LIONPATH_SFTP_SERVER'], ENV['LIONPATH_SFTP_USER'], key_data: [ENV['LIONPATH_SSH_KEY']])
    file = sftp.dir
               .glob("out/", LIONPATH_FILE_PATTERNS[:committee_role] + "*")
               .reject { |f| f.name.starts_with?('.') }
               .select(&:file?)
               .max { |a, b| a.attributes.mtime <=> b.attributes.mtime }

    sftp.download!("out/#{file.name}", lionpath_csv_loc)
  end

  private

    def grab_file(resource)
      if resource.is_a?(Lionpath::LionpathCommitteeRoles)
        sftp_download(LIONPATH_FILE_PATTERNS[:committee_role])
      elsif resource.is_a?(Lionpath::LionpathProgram)
        sftp_download(LIONPATH_FILE_PATTERNS[:program])
      elsif resource.is_a?(Lionpath::LionpathCommittee)
        sftp_download(LIONPATH_FILE_PATTERNS[:committee])
      else
        raise InvalidResource
      end
    end

    def parse_csv(resource)
      csv_options = { headers: true, encoding: "ISO-8859-1:UTF-8", quote_char: '"', force_quotes: true }
      CSV.foreach(lionpath_csv_loc, csv_options) do |row|
        resource.import(row)
      rescue StandardError => e
        Rails.logger.error(error_json(e, resource))
      end
    end

    def error_json(error, resource)
      {
        lionpath: {
          error: error.to_s,
          resource: resource.class.name,
          timestamp: DateTime.now
        }
      }.to_json
    end

    def lionpath_csv_loc
      "#{tmp_dir}lionpath.csv"
    end

    def tmp_dir
      "#{Rails.root}/tmp/"
    end

    def bin_path
      "#{Rails.root}/bin/lionpath-csv.sh"
    end
end
