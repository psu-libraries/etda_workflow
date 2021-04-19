class AddLionpathImportAtColumnToProgramsCommitteeMembersAndSubmission < ActiveRecord::Migration[6.0]
  def self.up
    add_column :submissions, :lionpath_upload_finished_at, :datetime
    add_column :programs, :lionpath_uploaded_at, :datetime
    add_column :committee_members, :lionpath_uploaded_at, :datetime
  end

  def self.down
    remove_column :submissions, :lionpath_upload_finished_at
    remove_column :programs, :lionpath_uploaded_at
    remove_column :committee_members, :lionpath_uploaded_at
  end
end
