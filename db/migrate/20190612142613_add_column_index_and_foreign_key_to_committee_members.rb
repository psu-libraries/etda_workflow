class AddColumnIndexAndForeignKeyToCommitteeMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :committee_members, :approver_id, :bigint
    add_index :committee_members, :approver_id
    add_foreign_key :committee_members, :approvers, name: :committee_members_approver_id_fk
  end
end
