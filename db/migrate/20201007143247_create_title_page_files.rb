class CreateTitlePageFiles < ActiveRecord::Migration[6.0]
  def self.up
    create_table :title_page_files do |t|
      t.bigint :submission_id
      t.text :asset

      t.timestamps
    end
    add_foreign_key :title_page_files, :submissions, name: :title_page_files_submission_id_fk
  end

  def self.down
    remove_foreign_key :title_page_files, name: "title_page_files_submission_id_fk"
    drop_table :title_page_files
  end
end
