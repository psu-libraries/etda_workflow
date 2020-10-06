class CreateProquestFiles < ActiveRecord::Migration[6.0]
  def self.up
    create_table :proquest_files do |t|
      t.bigint :submission_id
      t.text :asset

      t.timestamps
    end
    add_foreign_key :proquest_files, :submissions, name: :proquest_files_submission_id_fk
  end

  def self.down
    remove_foreign_key :proquest_files, name: "proquest_files_submission_id_fk"
    drop_table :proquest_files
  end
end
