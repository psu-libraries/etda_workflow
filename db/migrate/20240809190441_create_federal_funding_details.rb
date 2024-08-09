class CreateFederalFundingDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :federal_funding_details do |t|
      t.boolean :training_support_funding
      t.boolean :other_funding
      t.boolean :training_support_acknowledged
      t.boolean :other_funding_acknowledged
      t.belongs_to :submission, null: false, foreign_key: true

      t.timestamps
    end
  end
end
