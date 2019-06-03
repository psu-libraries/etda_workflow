class AddDefaultToCommitteeMemberStatus < ActiveRecord::Migration[5.1]
  def change
    change_column_default :committee_members, :status, ''
  end
end
