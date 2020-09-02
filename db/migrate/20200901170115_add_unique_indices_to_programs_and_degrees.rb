class AddUniqueIndicesToProgramsAndDegrees < ActiveRecord::Migration[6.0]
  def self.up
    add_index :degrees, :name, unique: true
    add_index :programs, [:name, :code], unique: true
  end

  def self.down
    remove_index :degrees, column: :name
    remove_index :programs, column: [:name, :code]
  end
end
