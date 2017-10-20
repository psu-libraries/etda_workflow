class CreateFinalSubmissionFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :final_submission_files do |t|
        t.bigint :submission_id
        t.text :asset
        t.integer :legacy_id

        t.timestamps
    end
  end
end
