class AddAdminEditedAtToAuthors < ActiveRecord::Migration[6.0]
  def self.up
    add_column :authors, :admin_edited_at, :datetime
  end

  def self.down
    remove_column :authors, :admin_edited_at
  end
end
