class ChangeLionpathUploadedAtColumnsToLionpathUpdatedAt < ActiveRecord::Migration[6.0]
  def self.up
    add_column :submissions, :lionpath_updated_at, :datetime
    add_column :program_chairs, :lionpath_updated_at, :datetime
    rename_column :committee_members, :lionpath_uploaded_at, :lionpath_updated_at
    rename_column :programs, :lionpath_uploaded_at, :lionpath_updated_at
  end

  def self.down
    remove_column :submissions, :lionpath_updated_at
    remove_column :program_chairs, :lionpath_updated_at
    rename_column :committee_members, :lionpath_updated_at, :lionpath_uploaded_at
    rename_column :programs, :lionpath_updated_at, :lionpath_uploaded_at
  end
end
