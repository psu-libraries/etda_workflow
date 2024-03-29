class RemoveProgramChairs < ActiveRecord::Migration[6.0]
  def self.up
    remove_foreign_key :program_chairs, name: "program_chairs_program_id_fk"
    drop_table :program_chairs
  end

  def self.down
    create_table :program_chairs do |t|
      t.bigint :program_id, null: false
      t.string :access_id, null: false
      t.string :first_name
      t.string :last_name
      t.string :campus
      t.bigint :phone
      t.string :email
    end
    add_index :program_chairs, :program_id, unique: true
    add_foreign_key :program_chairs, :programs, name: :program_chairs_program_id_fk, dependent: :delete
  end
end
