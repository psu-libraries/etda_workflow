class AddCodeToCommitteeRoles < ActiveRecord::Migration[6.0]
  def self.up
    add_column :committee_roles, :code, :string
  end

  def self.down
    remove_column :committee_roles, :code
  end
end
