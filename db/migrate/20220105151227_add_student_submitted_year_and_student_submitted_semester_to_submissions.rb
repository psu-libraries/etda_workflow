class AddStudentSubmittedYearAndStudentSubmittedSemesterToSubmissions < ActiveRecord::Migration[6.0]
  def self.up
    add_column :submissions, :author_submitted_year, :integer
    add_column :submissions, :author_submitted_semester, :string
    Submission.find_each do |submission|
      submission.update author_submitted_year: submission.year
      submission.update author_submitted_semester: submission.semester
    end
  end

  def self.down
    remove_column :submissions, :author_submitted_year
    remove_column :submissions, :author_submitted_semester
  end
end
