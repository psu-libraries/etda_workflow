class UpdateCommitteMemberFacultyMemberForeignKeyToFacultyMember < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :committee_members, :faculty_members, name: :committee_members_faculty_member_id_fk
    add_foreign_key :committee_members, :faculty_members, name: :committee_members_faculty_member_id_fk, on_delete: :nullify
  end
end
