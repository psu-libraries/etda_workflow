class CreateSedFiles < ActiveRecord::Migration[6.0]
  def self.up
    create_table :sed_files do |t|
      t.bigint :submission_id
      t.text :asset

      t.timestamps
    end
    add_foreign_key :sed_files, :submissions, name: :sed_files_submission_id_fk
  end

  def self.down
    remove_foreign_key :sed_files, name: "sed_files_submission_id_fk"
    drop_table :sed_files
  end
end
