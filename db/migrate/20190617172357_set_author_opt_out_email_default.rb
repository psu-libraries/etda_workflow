class SetAuthorOptOutEmailDefault < ActiveRecord::Migration[5.1]
  def change
    change_column :authors, :opt_out_email, :boolean, default: true
  end
end
