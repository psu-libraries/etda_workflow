class CreateForeignKeys < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :final_submission_files, :submissions, name: :final_submission_files_submission_id_fk
    add_foreign_key :format_review_files, :submissions, name: :format_review_files_submission_id_fk
  end
end
