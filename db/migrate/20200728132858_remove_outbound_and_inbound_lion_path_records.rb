class RemoveOutboundAndInboundLionPathRecords < ActiveRecord::Migration[6.0]
  def self.up
    remove_foreign_key :inbound_lion_path_records, name: 'inbound_lion_path_records_author_id_fk'
    drop_table :inbound_lion_path_records
    drop_table :outbound_lion_path_records
  end

  def self.down
    create_table :inbound_lion_path_records do |t|
      t.bigint :author_id
      t.string :lion_path_degree_code
      t.text :current_data

      t.timestamps null: true
    end
    create_table :outbound_lion_path_records do |t|
      t.text :status_data
      t.boolean :received
      t.string :transaction_id
      t.bigint :submission_id

      t.timestamps null: true
    end
    add_foreign_key :inbound_lion_path_records, :authors, name: 'inbound_lion_path_records_author_id_fk'
  end
end
