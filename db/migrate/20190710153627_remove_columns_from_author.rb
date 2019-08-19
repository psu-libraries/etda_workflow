class RemoveColumnsFromAuthor < ActiveRecord::Migration[5.1]
  def change
    remove_column :authors, :opt_out_email
    remove_column :authors, :opt_out_default
  end
end
