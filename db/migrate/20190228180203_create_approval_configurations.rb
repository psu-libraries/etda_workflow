class CreateApprovalConfigurations < ActiveRecord::Migration[5.1]
  def change
    create_table :approval_configurations do |t|
      t.bigint :degree_type_id
      t.date :approval_deadline_on
      t.integer :rejections_permitted

      t.timestamps
    end

    add_foreign_key :approval_configurations, :degree_types, name: :degree_type_id_fk, dependent: :delete
  end
end
