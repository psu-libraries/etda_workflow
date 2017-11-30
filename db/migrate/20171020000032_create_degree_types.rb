class CreateDegreeTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :degree_types do |t|
      t.string :name, null:false
      t.string :slug, null:false
    end
    add_index :degree_types, :name, unique: true
    add_index :degree_types, :slug, unique: true
  end
end
