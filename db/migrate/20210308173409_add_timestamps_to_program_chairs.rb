class AddTimestampsToProgramChairs < ActiveRecord::Migration[6.0]
  def self.up
    add_timestamps :program_chairs
  end

  def self.down
    remove_timestamps :program_chairs
  end
end
