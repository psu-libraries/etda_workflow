class RemoveAndChangeColumnsInApprovalConfigurations < ActiveRecord::Migration[5.1]
  def change
    remove_column :approval_configurations, :percentage_for_approval
    rename_column :approval_configurations, :rejections_permitted, :configuration_threshold
  end
end
