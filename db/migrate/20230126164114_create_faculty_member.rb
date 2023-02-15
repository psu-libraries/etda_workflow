class CreateFacultyMember < ActiveRecord::Migration[6.0]
  def change
    create_table :faculty_members do |t|
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name,  null: false
      t.string :department
      t.string :webaccess_id, null: false
    end
    add_column :committee_members, :faculty_member_id, :bigint

    add_foreign_key :committee_members, :faculty_members, name: :committee_members_faculty_member_id_fk
    add_index :faculty_members, :webaccess_id, unique: true
  end
end
