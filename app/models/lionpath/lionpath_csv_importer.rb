class Lionpath::LionpathCsvImporter
  class InvalidResource < StandardError; end
  class InvalidPartner < StandardError; end

  # Order is essential here; Do not change.
  LIONPATH_RESOURCES = [
    Lionpath::LionpathProgram.new,
    Lionpath::LionpathChair.new,
    Lionpath::LionpathCommittee.new
  ].freeze

  def import
    raise InvalidPartner unless current_partner.graduate?

    LIONPATH_RESOURCES.each do |resource|
      grab_file(resource)
      parse_csv(resource)
    end
    assign_chairs
  end

  private

  def grab_file(resource)
    if resource.is_a?(Lionpath::LionpathProgram)
      `#{program_bin_path}`
    elsif resource.is_a?(Lionpath::LionpathChair)
      `#{chair_bin_path}`
    elsif resource.is_a?(Lionpath::LionpathCommittee)
      `#{committee_bin_path}`
    else
      raise InvalidResource
    end
  end

  def clear_tmp_directory
    `rm -v #{tmp_dir}*`
  end

  def assign_chairs
    submissions = Submission.where('submissions.created_at >= ?', DateTime.strptime('2021-01-01', '%Y-%m-%d'))
    submissions.each do |sub|
      degree_type = sub.degree.degree_type
      chair_role = CommitteeRole.find_by(name: 'Program Head/Chair', degree_type: degree_type)
      sub_chair = sub.committee_members.find_by(committee_role_id: chair_role.id)
      program_chair = sub.program.program_chairs.find { |n| n.campus == sub.campus }
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
                                            is_required: false,
                                            is_voting: false,
                                            lionpath_updated_at: DateTime.now
      sub.committee_members << chair_member
      sub.save!
    end
  end

  def lionpath_csv_loc
    "#{tmp_dir}lionpath.csv"
  end

  def tmp_dir
    '/var/tmp_lionpath/'
  end

  def parse_csv(resource)
    csv_options = { headers: true, encoding: "ISO-8859-1:UTF-8", quote_char: '"', force_quotes: true }
    CSV.foreach(lionpath_csv_loc, csv_options) do |row|
      resource.import(row)
    end
  end

  def bin_path
    "#{Rails.root}/bin/"
  end

  def program_bin_path
    bin_path + 'lionpath-program.sh'
  end

  def chair_bin_path
    bin_path + 'lionpath-chair.sh'
  end

  def committee_bin_path
    bin_path + 'lionpath-committee.sh'
  end
end
