class AddPercentageForApprovalAndUsePercentageToApprovalConfigurations < ActiveRecord::Migration[5.1]
  def change
    add_column :approval_configurations, :percentage_for_approval, :decimal
    add_column :approval_configurations, :use_percentage, :boolean
  end
end
