# frozen_string_literal: true

class RemoveHoldColumnsFromSubmissions < ActiveRecord::Migration[7.0]
  def change
    remove_column :submissions, :placed_on_hold_at, :datetime
    remove_column :submissions, :removed_hold_at, :datetime
  end
end
