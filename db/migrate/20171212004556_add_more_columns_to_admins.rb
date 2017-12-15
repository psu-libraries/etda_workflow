class AddMoreColumnsToAdmins < ActiveRecord::Migration[5.1]
  def change
    add_column :admins, :first_name, :string
    add_column :admins, :last_name, :string
    add_column :admins, :psu_email_address, :string
    add_column :admins, :address_1, :string
    add_column :admins, :phone_number, :string
    add_column :admins, :psu_idn, :string
    add_column :admins, :administrator, :boolean
    add_column :admins, :site_administrator, :boolean
  end
end
