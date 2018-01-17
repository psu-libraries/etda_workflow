# frozen_string_literal: true

class CreateInventionDisclosures < ActiveRecord::Migration[5.1]
  def change
    create_table :invention_disclosures do |t|
      t.bigint :submission_id
      t.string :id_number

      t.timestamps
    end
  end
end
