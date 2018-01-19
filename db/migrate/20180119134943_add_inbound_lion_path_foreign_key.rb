class AddInboundLionPathForeignKey < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :inbound_lion_path_records, :authors, name: 'inbound_lion_path_records_author_id_fk'
  end

  def self.down
    remove_foreign_key :inbound_lion_path_records, name: 'inbound_lion_path_records_author_id_fk'
  end
end
