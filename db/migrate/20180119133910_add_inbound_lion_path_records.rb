class AddInboundLionPathRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :inbound_lion_path_records do |t|
      t.bigint :author_id
      t.string :lion_path_degree_code
      t.text :current_data

      t.timestamps null: true
    end
  end

  def self.down
    drop_table :inbound_lion_path_records
  end
end
