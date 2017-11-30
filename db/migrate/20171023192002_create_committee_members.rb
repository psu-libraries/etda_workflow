class CreateCommitteeMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :committee_members do |t|
      t.bigint :submission_id
      t.bigint :committee_role_id
      t.string :name
      t.string :email
      t.integer :legacy_id
      t.boolean :is_required

      t.timestamps
    end
    add_foreign_key :committee_members, :submissions, name: :committee_members_submission_id_fk
    add_foreign_key :committee_members, :committee_roles, name: :committee_members_committee_role_id_fk
  end
end
