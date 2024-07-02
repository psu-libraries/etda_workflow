class DropStudentSubmissionsView < ActiveRecord::Migration[6.1]
  def change
    execute <<-SQL
      drop view if exists `student_submissions`
    SQL
  end
end
