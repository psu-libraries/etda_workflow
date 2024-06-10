class AddAuthorReleaseWarningSentAtToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :author_release_warning_sent_at, :datetime
  end
end
