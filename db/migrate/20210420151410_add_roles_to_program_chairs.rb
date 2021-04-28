class AddRolesToProgramChairs < ActiveRecord::Migration[6.0]
  def self.up
    add_column :program_chairs, :role, :string
  end

  def self.down
    remove_column :program_chairs, :role
  end
end
