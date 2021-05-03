class AddIsProgramHeadToCommitteeRoles < ActiveRecord::Migration[6.0]
  def self.up
    add_column :committee_roles, :is_program_head, :boolean
  end

  def self.down
    remove_column :committee_roles, :is_program_head
  end
end
