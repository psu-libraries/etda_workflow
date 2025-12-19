class CreateRemediatedFinalSubmissionFiles < ActiveRecord::Migration[7.2]
  def change
    create_table :remediated_final_submission_files do |t|
      t.bigint :submission_id
      t.bigint :final_submission_file_id
      t.text :asset

      t.timestamps
    end
  end
end
