class CreateConfidentialHoldHistory < ActiveRecord::Migration[5.1]
  def change
    create_table :confidential_hold_histories do |t|
      t.bigint :author_id, null: false
      t.datetime :set_at
      t.datetime :removed_at
      t.string :set_by
      t.string :removed_by

      t.timestamps
    end
    add_index :confidential_hold_histories, :author_id

    add_foreign_key :confidential_hold_histories, :authors, name: :confidential_hold_histories_author_id_fk
  end
end
