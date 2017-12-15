require 'net/ldap'

class LdapUniversityDirectory
  class Error < RuntimeError; end
  class UnreachableError < Error; end
  class ResultError < Error; end

  def autocomplete(term_given)
    term = term_given
    return [] unless searchterm_valid?(term)
    term = term.strip!

    ldap_records = []

    with_connection do |connection|
      autocomplete_search_filter = LdapSearchFilter.new(term, true).create_filter
      ldap_records = connection.search(base: ldap_configuration['base'],
                                       filter: autocomplete_search_filter,
                                       attributes: %w( cn displayname mail psadminarea psdepartment ),
                                       return_result: true) # was size: 200

      if connection.get_operation_result.message == "Size Limit Exceeded"
        return []
      else
        raise ResultError, connection.get_operation_result.message unless connection.get_operation_result.message == 'Success'
      end
    end
    if ldap_records.present?
      mapped_attributes = LdapResult.new(ldap_record: ldap_records,
                                         attribute_map: LdapResultsMap::AUTOCOMPLETE_LDAP_MAP[:map],
                                         defaults:  LdapResultsMap::AUTOCOMPLETE_LDAP_MAP[:defaults]).map_directory_info
      return mapped_attributes
    end
    []
  end

  def exists?(psu_access_id)
    # result = nil
    result = retrieve(psu_access_id, LdapResultsMap::AUTHOR_LDAP_MAP).present?
    return false if result.nil?
    result.present?
  end

  def retrieve(psu_access_id, attributes_map)
    return {} if string_has_wildcard_character? psu_access_id
    ldap_record = directory_lookup('uid', psu_access_id)
    mapped_attributes = LdapResult.new(ldap_record: ldap_record,
                                       attribute_map: attributes_map).map_directory_info
    return {} if mapped_attributes.nil? || mapped_attributes.empty?

    mapped_attributes.first
  end

  def authors_confidential_status(this_access_id)
    attr = get_ldap_attribute(this_access_id, 'psconfhold')
    ActiveModel::Type::Boolean.new.cast(attr.downcase)
  end

  def get_psu_id_number(this_access_id)
    get_ldap_attribute(this_access_id, 'psidn')
  end

  def in_admin_group?(this_access_id)
    result = get_ldap_attribute(this_access_id, 'psmemberof')
    return false if result.nil? || result.empty?
    return true if result.include? "cn=umg/psu.sas.etda-#{current_partner.id}-admins,dc=psu,dc=edu"
    return true if result.include? "cn=umg/psu.dsrd.etda_#{current_partner.id}_admin_users,dc=psu,dc=edu"
    false
  end

  private

    def get_ldap_attribute(this_access_id, this_attribute)
      attrs = directory_lookup('uid', this_access_id)
      return '' if attrs.nil? || attrs.empty?
      return attrs.first[this_attribute].first unless this_attribute == 'psmemberof'
      attrs.first[this_attribute]
    end

    def ldap_configuration
      # Only ever read this once.
      @ldap_configuration ||= YAML.load_file('config/ldap.yml')[Rails.env].freeze
    end

    def directory_lookup(query_type, search_string)
      attrs = []
      with_connection do |conn|
        attrs = conn.search(base: ldap_configuration['base'], filter: Net::LDAP::Filter.eq(query_type, search_string), attributes: attrs)
        raise ResultError, conn.get_operation_result.message if attrs.nil?
      end
      attrs
    end

    def with_connection
      Net::LDAP.open(host: ldap_configuration['host'],
                     port: ldap_configuration['port'],
                     encryption: { method: :simple_tls },
                     auth: { method: :simple, username: "cn=#{ldap_configuration['user']},dc=psu,dc=edu",
                             password: ldap_configuration['password'] }) do |connection|
        yield connection
      end
    rescue Net::LDAP::LdapError
      raise UnreachableError
    end

    def string_has_wildcard_character?(term)
      (term =~ /\*/) != nil
    end

    def searchterm_valid?(term)
      result = term.present? && term =~ /^[a-z '\-]+$/i
      result
    end
end
