class Lionpath::LionpathCsvImporter
  class InvalidResource < StandardError; end
  class InvalidPartner < StandardError; end

  # Order is essential here; Do not change.
  LIONPATH_RESOURCES = [
    Lionpath::LionpathProgram.new,
    Lionpath::LionpathChair.new,
    Lionpath::LionpathCommittee.new
  ].freeze

  # Patterns sftp will look for when pulling csv file
  LIONPATH_FILE_PATTERNS = {
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
    assign_chairs
    File.delete(lionpath_csv_loc) if File.exist?(lionpath_csv_loc)
  end

  private

  def grab_file(resource)
    if resource.is_a?(Lionpath::LionpathProgram)
      `#{bin_path} #{LIONPATH_FILE_PATTERNS[:program]}`
    elsif resource.is_a?(Lionpath::LionpathChair)
      `#{bin_path} #{LIONPATH_FILE_PATTERNS[:chair]}`
    elsif resource.is_a?(Lionpath::LionpathCommittee)
      `#{bin_path} #{LIONPATH_FILE_PATTERNS[:committee]}`
    else
      raise InvalidResource
    end
  end

  def assign_chairs
    submissions = Submission.where('submissions.year >= ?', 2021)
    submissions.each do |sub|
      degree_type = sub.degree.degree_type
      chair_role = CommitteeRole.find_by(name: 'Program Head/Chair', degree_type: degree_type)
      sub_chair = sub.committee_members.find_by(committee_role_id: chair_role.id)
      program_chair = sub.program.program_chairs.find { |n| n.campus == sub.campus }
      next if program_chair.blank?

      if sub_chair.present?
        sub_chair.update name: "#{program_chair.first_name} #{program_chair.last_name}",
                         email: program_chair.email,
                         access_id: program_chair.access_id,
                         lionpath_updated_at: DateTime.now
        next
      end
      chair_member = CommitteeMember.create committee_role_id: chair_role.id,
                                            name: "#{program_chair.first_name} #{program_chair.last_name}",
                                            email: program_chair.email,
                                            access_id: program_chair.access_id,
                                            is_required: true,
                                            is_voting: false,
                                            lionpath_updated_at: DateTime.now
      sub.committee_members << chair_member
      sub.save!
    rescue StandardError => e
      Rails.logger.error(error_json(e, "Assigning Chairs"))
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
