# frozen_string_literal: true

class Author < ApplicationRecord
  class NotAuthorizedToEdit < StandardError; end

  Devise.add_module(:webaccess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable

  has_many :submissions, dependent: :nullify
  has_many :confidential_hold_histories, dependent: :destroy

  # validate for author
  validates :access_id,
            :first_name,
            :last_name,
            :psu_email_address,
            :alternate_email_address,
            :psu_idn, presence: true

  validates :access_id, uniqueness: { case_sensitive: true }

  validates :psu_idn,
            :legacy_id, allow_blank: true,
                        allow_nil: true,
                        uniqueness: { case_sensitive: true }

  # validate for graduate authors only
  validates :phone_number,
            :address_1,
            :city,
            :state,
            :zip, presence: true, if: proc { current_partner.graduate? }

  validates :alternate_email_address,
            :psu_email_address,
            format: { with: /\A[\w]([^@\s,;]+)@(([\w-]+\.)+([\w]+))\z/i }

  validates :zip, format: { with: /\A\d{5}-\d{4}\z|\A\d{5}\z/, message: "Must be in the format '12345' or '12345-1234'" }, if: proc { current_partner.graduate? }

  validates :psu_idn, format: { with: /\A(^9\d{8})\z/ }

  validates :state, inclusion: { in:  UsStates.names.keys.map(&:to_s) }, if: proc { current_partner.graduate? }

  def psu_id
    psu_idn || ''
  end

  def self.current
    Thread.current[:author]
  end

  def self.current=(author)
    Thread.current[:author] = author
  end

  def full_name
    return access_id if first_name.nil? || last_name.nil?
    return first_name + ' ' + last_name if middle_name.blank?

    first_name + ' ' + middle_name + ' ' + last_name
  end

  def populate_attributes
    populate_with_ldap_attributes(access_id,'uid')
    self
  end

  def populate_with_ldap_attributes(input_string, query_type)
    results = LdapUniversityDirectory.new.retrieve(input_string, query_type, LdapResultsMap::AUTHOR_LDAP_MAP)
    # raise an error unless ldap_results_valid?(results)
    save_mapped_attributes(results) if results
  end

  def psu_id_number(access_id)
    id_number = LdapUniversityDirectory.new.get_psu_id_number(access_id)
    id_number.nil? ? ' ' : id_number
  end

  def refresh_important_attributes
    # do not overwrite address, phone, etc.
    ldap_attributes = LdapUniversityDirectory.new.retrieve(access_id, 'uid', LdapResultsMap::AUTHOR_LDAP_MAP)
    return if ldap_attributes.empty?

    self.first_name = refresh(first_name, ldap_attributes[:first_name])
    self.last_name = refresh(last_name, ldap_attributes[:last_name])
    self.middle_name = refresh(middle_name, ldap_attributes[:middle_name])
    self.psu_email_address = refresh(psu_email_address, ldap_attributes[:psu_email_address])
    self.psu_idn = refresh(psu_idn, ldap_attributes[:psu_idn])
    save(validate: false)
    self
  end

  def unpublished_submissions
    current_submissions = []
    submissions.order(created_at: :desc).each do |s|
      current_submissions << s unless s.status_behavior.released_for_publication?
    end
    current_submissions
  end

  def can_edit?
    raise NotAuthorizedToEdit unless access_id.downcase.strip == Author.current.access_id.downcase.strip

    true
  end

  def legacy?
    legacy_id.present?
  end

  def confidential?
    confidential_hold || false
  end

  private

    def ldap_results_valid?(results)
      if results.blank?
        Rails.logger.info("No LDAP information returned for #{access_id}")
        false
      else
        ldap_access_id_valid?(results)
      end
    end

    def ldap_access_id_valid?(results)
      ldap_access_id = results[:access_id].downcase.strip
      author_access_id = access_id.downcase.strip
      if ldap_access_id != author_access_id
        Rails.logger.info("Incorrect access id retrieved from LDAP.  LDAP returned: #{ldap_access_id} for author: #{author_access_id}")
        return false
      end
      true
    end

    def refresh(original_val, new_val)
      return original_val if new_val.blank?

      new_val
    end

    def save_mapped_attributes(mapped_attributes)
      if mapped_attributes[:confidential_hold]
        # name unavailable bc of confidential hold; use access id
        mapped_attributes[:first_name] = access_id if mapped_attributes[:first_name].blank?
        mapped_attributes[:last_name] = 'No Associated Name' if mapped_attributes[:last_name].blank?
      end
      update(mapped_attributes)
      save(validate: false)
    end
end
