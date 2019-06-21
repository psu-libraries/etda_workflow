class AddHeadOfProgramIsApprovingToApprovalConfiguration < ActiveRecord::Migration[5.1]
  def change
    add_column :approval_configurations, :head_of_program_is_approving, :boolean
  end
end
