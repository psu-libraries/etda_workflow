class AddPlacedOnHoldAtToSubmissions < ActiveRecord::Migration[5.1]
  def change
    add_column :submissions, :placed_on_hold_at, :datetime
    add_column :submissions, :removed_hold_at, :datetime
  end
end
