class AddIsVotingToCommitteeMembers < ActiveRecord::Migration[5.1]
  def change
    add_column :committee_members, :is_voting, :boolean, default: false
  end
end
