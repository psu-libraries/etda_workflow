class AddMoreColumnsToCommitteeMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :committee_members, :access_id, :string
    add_column :committee_members, :approval_started_at, :datetime
    add_column :committee_members, :approved_at, :datetime
    add_column :committee_members, :rejected_at, :datetime
    add_column :committee_members, :reset_at, :datetime
    add_column :committee_members, :last_notified_at, :datetime
    add_column :committee_members, :last_notified_type, :string
    add_column :committee_members, :notes, :text
  end
end
