# frozen_string_literal: true

require 'net/ldap'

class LdapUniversityDirectory
  class Error < RuntimeError; end
  class UnreachableError < Error; end
  class ResultError < Error; end

  def autocomplete(term_given)
    term = term_given
    return [] unless searchterm_valid?(term)

    ldap_records = []

    with_connection do |connection|
      autocomplete_search_filter = LdapSearchFilter.new(term, true).create_filter
      ldap_records = connection.search(base: ldap_configuration['base'],
                                       filter: autocomplete_search_filter,
                                       attributes: %w[cn displayname mail psadminarea psdepartment],
                                       return_result: true) # was size: 200

      return [] if connection.get_operation_result.message == "Size Limit Exceeded"
      raise ResultError, connection.get_operation_result.message unless connection.get_operation_result.message == 'Success'
    end
    if ldap_records.present?
      mapped_attributes = LdapResult.new(ldap_record: ldap_records,
                                         attribute_map: LdapResultsMap::AUTOCOMPLETE_LDAP_MAP[:map],
                                         defaults: LdapResultsMap::AUTOCOMPLETE_LDAP_MAP[:defaults]).map_directory_info
      return mapped_attributes
    end
    []
  end

  def exists?(psu_access_id)
    # result = nil
    result = retrieve(psu_access_id, 'uid', LdapResultsMap::AUTHOR_LDAP_MAP).present?
    return false if result.nil?

    result.present?
  end

  def retrieve(input_string, query_type, attributes_map)
    return {} if string_has_wildcard_character? input_string

    ldap_record = directory_lookup(query_type.to_s, input_string)
    mapped_attributes = LdapResult.new(ldap_record:,
                                       attribute_map: attributes_map).map_directory_info
    return {} if mapped_attributes.blank?

    mapped_attributes.first
  end

  def retrieve_committee_access_id(psu_email)
    ldap_record = directory_lookup('psMailID', psu_email)
    mapped_attributes = LdapResult.new(ldap_record:,
                                       attribute_map: LdapResultsMap::COMMITTEE_LDAP_MAP).map_directory_info
    return nil if mapped_attributes.blank?

    mapped_attributes.first[:access_id]
  rescue UnreachableError
    nil
  end

  def authors_confidential_status(this_access_id)
    attr = get_ldap_attribute(this_access_id, 'psconfhold')
    return false if attr.nil?

    ActiveModel::Type::Boolean.new.cast(attr.downcase)
  end

  def get_psu_id_number(this_access_id)
    get_ldap_attribute(this_access_id, 'psidn')
  end

  def in_admin_group?(this_access_id)
    result = get_ldap_attribute(this_access_id, 'psmemberof')
    return false if result.blank?
    return true if result.include? "cn=umg/psu.sas.etda-#{current_partner.id}-admins,dc=psu,dc=edu"
    return true if result.include? "cn=umg/psu.dsrd.etda_#{current_partner.id}_admin_users,dc=psu,dc=edu"
    return true if result.include? "cn=umg/psu.etda_#{current_partner.id}_admin_users,dc=psu,dc=edu"

    false
  end

  def with_connection(&block)
    Net::LDAP.open(host: ldap_configuration['host'],
                   port: ldap_configuration['port'],
                   encryption: { method: :simple_tls },
                   auth: { method: :simple, username: "uid=#{ldap_configuration['user']},dc=psu,dc=edu",
                           password: ldap_configuration['password'] }, &block)
  rescue Net::LDAP::Error
    raise UnreachableError
  end

  private

    def get_ldap_attribute(this_access_id, this_attribute)
      attrs = directory_lookup('uid', this_access_id)
      return '' if attrs.blank?
      return attrs.first[this_attribute].first unless this_attribute == 'psmemberof'

      attrs.first[this_attribute]
    end

    def ldap_configuration
      # Only ever read this once.
      @ldap_configuration ||= Rails.application.config_for(:ldap)
    end

    def directory_lookup(query_type, search_string)
      attrs = []
      with_connection do |conn|
        attrs = conn.search(base: ldap_configuration['base'], filter: Net::LDAP::Filter.eq(query_type, search_string), attributes: attrs)
        raise ResultError, conn.get_operation_result.message if attrs.nil?
      end
      attrs
    end

    def string_has_wildcard_character?(term)
      (term =~ /\*/) != nil
    end

    def searchterm_valid?(term)
      return false if term.blank?
      return false unless term.present? && term =~ /^[a-zÀ-ÖØ-öø-ÿ '\-.]+$/i

      true
    end
end
