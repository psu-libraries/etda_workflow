class AddHeadOfProgramReviewTimestampsToSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_column :submissions, :head_of_program_review_accepted_at, :datetime
    add_column :submissions, :head_of_program_review_rejected_at, :datetime
  end
end
