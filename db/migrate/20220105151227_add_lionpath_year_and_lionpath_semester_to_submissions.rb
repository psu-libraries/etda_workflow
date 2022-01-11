class AddLionpathYearAndLionpathSemesterToSubmissions < ActiveRecord::Migration[6.0]
  def self.up
    add_column :submissions, :lionpath_year, :integer
    add_column :submissions, :lionpath_semester, :string
    Submission.find_each do |submission|
      next unless submission.lionpath_updated_at.present?

      submission.update lionpath_year: submission.year
      submission.update lionpath_semester: submission.semester
    end
  end

  def self.down
    remove_column :submissions, :lionpath_year
    remove_column :submissions, :lionpath_semester
  end
end
