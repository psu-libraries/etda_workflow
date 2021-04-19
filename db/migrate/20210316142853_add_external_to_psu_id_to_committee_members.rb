class AddExternalToPsuIdToCommitteeMembers < ActiveRecord::Migration[6.0]
  def self.up
    add_column :committee_members, :external_to_psu_id, :string
  end

  def self.down
    remove_column :committee_members, :external_to_psu_id
  end
end
