class AddOutboundLionPathRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :outbound_lion_path_records do |t|
      t.text :status_data
      t.boolean :received
      t.string :transaction_id
      t.bigint :submission_id

      t.timestamps null: true
    end
  end

  def self.down
    drop_table :outbound_lion_path_records
  end
end
