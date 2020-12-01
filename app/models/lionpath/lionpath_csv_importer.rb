class Lionpath::LionpathCsvImporter
  class InvalidResource < StandardError; end

  # Order is essential here; Do not change.
  LIONPATH_RESOURCES = [
    Lionpath::LionpathProgram,
    Lionpath::LionpathChair,
    Lionpath::LionpathCommittee
  ].freeze

  def initialize
  end

  def import
    LIONPATH_RESOURCES.each do |resource|
      if resource.is_a?(Lionpath::LionpathProgram)
        `#{program_bin_path}`
      elsif resource.is_a?(Lionpath::LionpathChair)
        `#{chair_bin_path}`
      elsif resource.is_a?(Lionpath::LionpathCommittee)
        `#{committee_bin_path}`
      else
        raise InvalidResource
      end
      parse_csv(resource)
      # Tagging MUST happen AFTER csv is parsed
      # It's the only way to be sure the committees are complete and ready to be tagged
      tag_submissions_as_finished if resource.is_a?(Lionpath::LionpathCommittee)
    end
  end

  private

  def clear_tmp_directory
    `rm -v #{tmp_dir}*`
  end

  def tag_submissions_as_finished
    submissions = Submission.joins(:committee_members)
                            .where('submissions.lionpath_upload_finished_at IS NULL')
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
