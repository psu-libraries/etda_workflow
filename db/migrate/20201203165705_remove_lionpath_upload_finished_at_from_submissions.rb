class RemoveLionpathUploadFinishedAtFromSubmissions < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :submissions, :lionpath_upload_finished_at
  end

  def self.down
    add_column :submission, :lionpath_upload_finished_at, :datetime
  end
end
