class CreateExternalApps < ActiveRecord::Migration[7.2]
  def change
    create_table :external_apps do |t|
      t.string :name

      t.timestamps
    end

    add_index :external_apps, :name, unique: true
  end
end
