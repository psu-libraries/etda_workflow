# frozen_string_literal: true

class Admin < ApplicationRecord
  Devise.add_module(:webacess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable

  validates :access_id,
            :first_name,
            :last_name,
            :psu_email_address,
            :psu_idn,
            :administrator,
            :site_administrator,
            presence: true

  def self.current
    Thread.current[:admin]
  end

  def self.current=(admin)
    Thread.current[:admin] = admin
  end

  def administrator?
    administrator
  end

  def site_administrator?
    site_administrator
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def populate_attributes
    results = LdapUniversityDirectory.new.retrieve(access_id, LdapResultsMap::ADMIN_LDAP_MAP)
    mapped_attributes = results.except(:access_id)
    save_mapped_attributes(mapped_attributes) if mapped_attributes
  end

  def save_mapped_attributes(mapped_attributes)
    update_attributes(mapped_attributes)
    save(validate: false)
  end

  def update_missing_attributes; end
end
