class AddAcknowledgementPageToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :acknowledgment_page_submitted_at, :datetime
  end
end
