class CreateDegrees < ActiveRecord::Migration[5.1]

  def change
    create_table :degrees do |t|
      t.string :name
      t.string :description
      t.boolean :is_active
      t.bigint :degree_type_id
      t.integer :legacy_id
      t.integer :legacy_old_id
      t.timestamps
      t.index :legacy_id
    end
    add_foreign_key :degrees, :degree_types, name: :degrees_degree_type_id_fk
  end
end
