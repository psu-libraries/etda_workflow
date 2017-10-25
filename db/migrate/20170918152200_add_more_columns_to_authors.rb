class AddMoreColumnsToAuthors < ActiveRecord::Migration[5.1]
  def change
    add_column :authors, :first_name, :string
    add_column :authors, :last_name, :string
    add_column :authors, :middle_name, :string
    add_column :authors, :alternate_email_address, :string
    add_column :authors, :is_alternate_email_public, :boolean
    add_column :authors, :psu_email_address, :string
    add_column :authors, :address_1, :string
    add_column :authors, :address_2, :string
    add_column :authors, :city, :string
    add_column :authors, :state, :string
    add_column :authors, :zip, :string
    add_column :authors, :country, :string
    add_column :authors, :phone_number, :string
    add_column :authors, :psu_idn, :string
    add_column :authors, :legacy_id, :integer
    add_column :authors, :confidential_hold, :boolean
    add_column :authors, :confidential_hold_set_at, :datetime
    add_column :authors, :is_admin, :boolean
    add_column :authors, :is_site_admin, :boolean
    add_index  :authors, :legacy_id
    # add_foreign_key :inbound_lion_path_records, :authors, name: 'inbound_lion_path_records_author_id_fk'
  end
end

