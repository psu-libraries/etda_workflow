class AddLastLionpathExportAtToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :last_lionpath_export_at, :datetime
  end
end
