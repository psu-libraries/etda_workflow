class Author < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :webaccess_authenticatable, :rememberable, :trackable, :registerable

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

  private

    def ldap_results_valid?(results)
      if results.nil? || results.empty?
        Rails.logger.info("No LDAP information returned for #{access_id}")
        return false
      else
        ldap_access_id_correct?(results)
      end
    end

    def ldap_access_id_correct?(results)
      ldap_access_id = results[:access_id].downcase.strip
      author_access_id = access_id.downcase.strip
      if ldap_access_id != author_access_id
        Rails.logger.info("Incorrect access id retrieved from LDAP.  LDAP returned: #{ldap_access_id} for author: #{author_access_id}")
        return false
      end
      true
    end
end
