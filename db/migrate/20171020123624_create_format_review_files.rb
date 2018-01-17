# frozen_string_literal: true

class CreateFormatReviewFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :format_review_files do |t|
      t.bigint :submission_id
      t.text :asset
      t.integer :legacy_id
      t.index :legacy_id

      t.timestamps
    end
  end
end
