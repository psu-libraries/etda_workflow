class CreateKeywords < ActiveRecord::Migration[5.1]
  def change
    create_table :keywords do |t|
      t.bigint :submission_id
      t.text :word
      t.integer :legacy_id
      t.timestamps
      t.index :legacy_id
    end
    add_foreign_key :keywords, :submissions, name: :keywords_submission_id_fk
  end

end
