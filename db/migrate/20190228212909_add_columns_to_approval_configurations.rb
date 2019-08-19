class AddColumnsToApprovalConfigurations < ActiveRecord::Migration[5.1]
  def change
    add_column :approval_configurations, :email_admins, :boolean
    add_column :approval_configurations, :email_authors, :boolean
  end
end
