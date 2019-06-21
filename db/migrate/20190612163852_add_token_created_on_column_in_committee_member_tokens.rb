class AddTokenCreatedOnColumnInCommitteeMemberTokens < ActiveRecord::Migration[5.1]
  def change
    add_column :committee_member_tokens, :token_created_on, :date
  end
end
