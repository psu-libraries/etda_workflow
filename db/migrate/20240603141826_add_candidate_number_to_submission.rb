class AddCandidateNumberToSubmission < ActiveRecord::Migration[6.1]
  def change
    add_column :submissions, :candidate_number, :integer
  end
end
