class AddTimestampsToCommitteeRoles < ActiveRecord::Migration[6.0]
  def self.up
    add_timestamps :committee_roles
    add_column :committee_roles, :lionpath_updated_at, :datetime
  end

  def self.down
    remove_timestamps :committee_roles
    remove_column :committee_roles, :lionpath_updated_at
  end
end
