class Author < ApplicationRecord
  class NotAuthorizedToEdit < StandardError; end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable

  # validate for author
  validates :access_id,
            :first_name,
            :last_name,
            :psu_email_address,
            :alternate_email_address,
            :psu_idn,
            presence: true

  # validate for graduate authors only
  validates :phone_number,
            :address_1,
            :city,
            :state,
            :zip, presence: true, if: proc { EtdaUtilities::Partner.current.graduate? }

  validates :alternate_email_address,
            :psu_email_address,
            format: { with: /\A[\w]([^@\s,;]+)@(([\w-]+\.)+([\w]+))/i }

  validates :zip, format: { with: /\A\d{5}-\d{4}\z|\A\d{5}\z/, message: "Must be in the format '12345' or '12345-1234'" }, if: proc { EtdaUtilities::Partner.current.graduate? }

  validates :psu_idn, format: { with: /\A(^9\d{8})\z/ }

  validates :state, inclusion: { in:  UsStates.names.keys.map(&:to_s) }, if: proc { EtdaUtilities::Partner.current.graduate? }

  def self.current
    Thread.current[:author]
  end

  def self.current=(author)
    Thread.current[:author] = author
  end

  def populate_attributes
    # result =
    populate_with_ldap_attributes
    # retrieve_lion_path_information unless result.nil?
  end

  def populate_with_ldap_attributes
    results = LdapUniversityDirectory.new.retrieve(access_id)
    # raise an error unless ldap_results_valid?(results)
    # mapped_attributes =
    results.except(:access_id)
    # save_mapped_attributes(mapped_attributes) if mapped_attributes
  end

  def retrieve_lion_path_information
  end

  def update_missing_attributes
    return unless psu_idn.blank?
    ldap_psu_idn = LdapUniversityDirectory.new.get_psu_id_number(access_id)
    update_attribute :psu_idn, ldap_psu_idn
  end

  def can_edit?
    raise NotAuthorizedToEdit unless access_id.downcase.strip == Author.current.access_id.downcase.strip
    true
  end

  def admin?
    is_admin
  end

  def site_admin?
    is_site_admin
  end

  def legacy?
    legacy_id.present?
  end

  # def academic_plan?
  #   return false if inbound_lion_path_record.nil?
  #   return false if inbound_lion_path_record.current_data.empty?
  #   true
  # end

  private

    def ldap_results_valid?(results)
      if results.nil? || results.empty?
        Rails.logger.info("No LDAP information returned for #{access_id}")
        return false
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
end
