# frozen_string_literal: true

class CreatePrograms < ActiveRecord::Migration[5.1]
  def change
    create_table :programs do |t|
      t.string :name
      t.string :description
      t.boolean :is_active
      t.integer :legacy_id
      t.integer :legacy_old_id
      t.timestamps
      t.index :legacy_id
    end
  end
end
