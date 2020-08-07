class AddCodeToPrograms < ActiveRecord::Migration[6.0]
  def self.up
    add_column :programs, :code, :string
  end

  def self.down
    remove_column :programs, :code
  end
end
