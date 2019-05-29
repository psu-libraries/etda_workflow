class AddFederalFundingUsedToCommitteeMember < ActiveRecord::Migration[5.1]
  def change
    add_column :committee_members, :federal_funding_used, :boolean
  end
end
