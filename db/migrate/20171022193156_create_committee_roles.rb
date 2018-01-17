# frozen_string_literal: true

class CreateCommitteeRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :committee_roles do |t|
      t.bigint :degree_type_id, null: false
      t.string :name, null: false
      t.integer :num_required, default: 0, null: false
      t.boolean :is_active, default: true, null: false
    end
    add_foreign_key :committee_roles, :degree_types, name: :committee_roles_degree_type_id_fk
  end
end
