class Lionpath::LionpathCsvImporter
  class InvalidResource < StandardError; end

  def initialize(lionpath_resource)
    @lionpath_resource = lionpath_resource
  end

  def import
    if lionpath_resource.is_a?(Lionpath::LionpathProgram)
      `#{program_bin_path}`
    elsif lionpath_resource.is_a?(Lionpath::LionpathChair)
      `#{chair_bin_path}`
    elsif lionpath_resource.is_a?(Lionpath::LionpathCommittee)
      `#{committee_bin_path}`
    else
      raise InvalidResource
    end
    parse_csv
    # Tagging MUST happen AFTER csv is parsed
    tag_submissions_as_finished if lionpath_resource.is_a?(Lionpath::LionpathCommittee)
  end

  private

  def clear_tmp_directory
    `rm -v #{tmp_dir}*`
  end

  def tag_submissions_as_finished
    submissions = Submission.joins(:committee_members)
                            .where('committee_members.lionpath_uploaded_at > ?', DateTime.yesterday)
                            .distinct(:id)
    submissions.each do |sub|
      sub.update lionpath_upload_finished_at: DateTime.now
    end
  end

  def lionpath_csv_loc
    "#{tmp_dir}lionpath.csv"
  end

  def tmp_dir
    '/var/tmp_lionpath/'
  end

  def parse_csv
    csv_options = { headers: true, encoding: "ISO-8859-1:UTF-8", quote_char: '"', force_quotes: true }
    CSV.foreach(lionpath_csv_loc, csv_options) do |row|
      lionpath_resource.import(row)
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

  attr_reader :lionpath_resource
end
