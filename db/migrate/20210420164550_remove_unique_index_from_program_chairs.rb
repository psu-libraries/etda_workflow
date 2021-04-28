class RemoveUniqueIndexFromProgramChairs < ActiveRecord::Migration[6.0]
  def self.up
    remove_foreign_key :program_chairs, :programs
    remove_index :program_chairs, :program_id
    add_foreign_key :program_chairs, :programs, name: :program_chairs_program_id_fk, dependent: :delete
  end

  def self.down
    add_index :program_chairs, :program_id, unique: true
  end
end
