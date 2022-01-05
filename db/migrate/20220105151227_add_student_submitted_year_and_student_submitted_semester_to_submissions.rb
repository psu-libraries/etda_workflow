class AddStudentSubmittedYearAndStudentSubmittedSemesterToSubmissions < ActiveRecord::Migration[6.0]
  def self.up
    add_column :submissions, :author_submitted_year, :integer
    add_column :submissions, :author_submitted_semester, :string
  end

  def self.down
    remove_column :submissions, :author_submitted_year
    remove_column :submissions, :author_submitted_semester
  end
end
