class AddEmailReminderAtToCommitteeMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :committee_members, :last_reminder_at, :datetime
  end
end
