class AddCollegeToFacultyMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :faculty_members, :college, :string
  end
end
