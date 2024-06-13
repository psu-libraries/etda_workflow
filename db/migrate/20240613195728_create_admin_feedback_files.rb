class CreateAdminFeedbackFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_feedback_files do |t|
      t.bigint :submission_id
      t.text :asset
      t.string :feedback_type

      t.timestamps
    end
  end
end
