class CreateFacultyMember < ActiveRecord::Migration[6.0]
  def change
    create_table :faculty_members do |t|
      t.string :first_name
      t.string :last_name
      t.string :webaccess_id, null: false, default: ""
    end
    add_foreign_key :faculty_members, :committee_members, name: :faculty_members_committee_id_fk
  end
end
