class AddStatusToCommitteeMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :committee_members, :status, :string
  end
end
