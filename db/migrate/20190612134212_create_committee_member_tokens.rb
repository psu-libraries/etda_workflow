class CreateCommitteeMemberTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :committee_member_tokens do |t|
      t.string :authentication_token
      t.bigint :committee_member_id

      t.timestamps
    end
    add_index :committee_member_tokens, :committee_member_id

    add_foreign_key :committee_member_tokens, :committee_members, name: :committee_member_tokens_committee_member_id_fk
  end
end
