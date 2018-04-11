class AddAltEmailOptOutToAuthor < ActiveRecord::Migration[5.1]
  def change
    add_column :authors, :opt_out_email, :boolean, default: false
    add_column :authors, :opt_out_default, :boolean, default: true
  end
end
