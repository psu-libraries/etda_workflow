class RemoveProgramIdUniqueIndexFromProgramChairs < ActiveRecord::Migration[6.0]
  def self.up
    remove_foreign_key :program_chairs, name: :program_chairs_program_id_fk
    remove_index :program_chairs, column: :program_id
    add_index :program_chairs, :program_id
    add_foreign_key :program_chairs, :programs, name: :program_chairs_program_id_fk, dependent: :delete
  end

  def self.down
    remove_foreign_key :program_chairs, name: :program_chairs_program_id_fk
    remove_index :program_chairs, column: :program_id
    add_index :program_chairs, :program_id, unique: true
    add_foreign_key :program_chairs, :programs, name: :program_chairs_program_id_fk, dependent: :delete
  end
end
