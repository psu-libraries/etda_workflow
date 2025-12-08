class AddDiscardedAtToCommitteeMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :committee_members, :discarded_at, :datetime
    add_index :committee_members, :discarded_at
  end
end
