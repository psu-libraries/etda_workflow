class CreateApiTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :api_tokens do |t|
      t.string :token
      t.datetime :last_used_at
      t.belongs_to :external_app, null: false, foreign_key: true

      t.timestamps
    end
  end
end
