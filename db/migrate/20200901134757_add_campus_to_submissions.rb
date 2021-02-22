class AddCampusToSubmissions < ActiveRecord::Migration[6.0]
  def self.up
    add_column :submissions, :campus, :string
  end

  def self.down
    remove_column :submissions, :campus
  end
end
