# frozen_string_literal: true

class CreateDegrees < ActiveRecord::Migration[5.1]
  def change
    create_table :degrees do |t|
      t.string :name
      t.string :description
      t.boolean :is_active
      t.integer :degree_type_id, null: false
      t.integer :legacy_id
      t.integer :legacy_old_id
      t.timestamps
      t.index :legacy_id
      t.index :degree_type_id
    end
  end
end
