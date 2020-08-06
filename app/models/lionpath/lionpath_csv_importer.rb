class Lionpath::LionpathCSVImporter
  class InvalidResource < StandardError; end

  def initialize(lionpath_resource)
    @lionpath_resource = lionpath_resource
  end

  def import
    if lionpath_resource.is_a?(LionpathProgram)
      `#{program_script_path}`
      Rake::Task['import:program_codes'].invoke(lionpath_csv_loc)
    elsif lionpath_resource.is_a?(LionpathChair)
      `#{chair_script_path}`
    elsif lionpath_resource.is_a?(LionpathCommittee)
      `#{committee_script_path}`
    else
      raise InvalidResource
    end
    parse_csv
    tag_submissions_as_finished if lionpath_resource.is_a?(LionpathCommittee)
  end

  private

  def tag_submissions_as_finished
    submissions = Submission.joins(:committee_members)
                            .where('committee_members.lionpath_uploaded_at > ?', DateTime.yesterday)
                            .distinct(:id)
    submissions.each do |sub|
      sub.update lionpath_upload_finished_at: DateTime.now
    end
  end

  def lionpath_csv_loc
    '/var/tmp_lionpath/lionpath.csv'
  end

  def parse_csv
    CSV.foreach(lionpath_csv_loc, headers: true) do |row|
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
