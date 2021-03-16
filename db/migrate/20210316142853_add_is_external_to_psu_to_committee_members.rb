class AddIsExternalToPsuToCommitteeMembers < ActiveRecord::Migration[6.0]
  def self.up
    add_column :committee_members, :is_external_to_psu, :boolean
  end

  def self.down
    remove_column :committee_members, :is_external_to_psu
  end
end
