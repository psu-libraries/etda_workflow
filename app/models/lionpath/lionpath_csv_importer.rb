class Lionpath::LionpathCsvImporter
  class InvalidResource < StandardError; end
  class InvalidPartner < StandardError; end

  # Order is essential here; Do not change.
  LIONPATH_RESOURCES = [
    Lionpath::LionpathCommitteeRoles.new,
    Lionpath::LionpathProgram.new,
    Lionpath::LionpathChair.new,
    Lionpath::LionpathCommittee.new
  ].freeze

  # Patterns sftp will look for when pulling csv file
  LIONPATH_FILE_PATTERNS = {
    committee_role: 'PE_SR_G_ETD_ACT_COMROLES',
    program: 'PE_SR_G_ETD_STDNT_PLAN_PRC',
    chair: 'PE_SR_G_ETD_CHAIR_PRC',
    committee: 'PE_SR_G_ETD_COMMITTEE_PRC'
  }.freeze

  def import
    raise InvalidPartner unless current_partner.graduate?

    LIONPATH_RESOURCES.each do |resource|
      grab_file(resource)
      parse_csv(resource)
    end
    File.delete(lionpath_csv_loc) if File.exist?(lionpath_csv_loc)
    Lionpath::LionpathDeleteExpiredRecords.delete
  end

  private

  def grab_file(resource)
    if resource.is_a?(Lionpath::LionpathCommitteeRoles)
      `#{bin_path} #{LIONPATH_FILE_PATTERNS[:committee_role]}`
    elsif resource.is_a?(Lionpath::LionpathProgram)
      `#{bin_path} #{LIONPATH_FILE_PATTERNS[:program]}`
    elsif resource.is_a?(Lionpath::LionpathChair)
      `#{bin_path} #{LIONPATH_FILE_PATTERNS[:chair]}`
    elsif resource.is_a?(Lionpath::LionpathCommittee)
      `#{bin_path} #{LIONPATH_FILE_PATTERNS[:committee]}`
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
