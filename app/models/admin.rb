# frozen_string_literal: true

class Admin < ApplicationRecord
  devise :oidc_authenticatable, :rememberable, :trackable, :registerable

  validates :access_id,
            :first_name,
            :last_name,
            :psu_email_address,
            :psu_idn,
            :administrator,
            presence: true

  validates :access_id, uniqueness: { case_sensitive: true }

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
    results = LdapUniversityDirectory.new.retrieve(access_id, 'uid', LdapResultsMap::ADMIN_LDAP_MAP)
    mapped_attributes = results.except(:access_id)
    save_mapped_attributes(mapped_attributes) if mapped_attributes
  end

  def save_mapped_attributes(mapped_attributes)
    update(mapped_attributes)
    save(validate: false)
  end

  def self.seed
    return if ENV['RAIL_ENV'] == 'production'
    return if ENV['ACCESS_ID'].blank?

    find_or_create_by!(access_id: ENV['ACCESS_ID']) do |r|
      r.first_name = ENV['FIRST_NAME']
      r.last_name = ENV['LAST_NAME']
      r.psu_email_address = ENV['PSU_EMAIL_ADDRESS']
      r.psu_idn = ENV['PSU_IDN']
      r.phone_number = '555-555-5555'
      r.administrator = true
      r.site_administrator = true
    end
  end
end
