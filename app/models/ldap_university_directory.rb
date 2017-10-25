require 'net/ldap'

class LdapUniversityDirectory
  class Error < RuntimeError; end
  class UnreachableError < Error; end
  class ResultError < Error; end

  def autocomplete(term, _only_faculty_staff)
    return [] unless term_is_valid?(term)
    ldap_records = []

    with_connection do |conn|
      10.times || ldap_records.present? do
        ldap_records = conn.search(base: ldap_configuration['base'],
                                   filter: LdapSearchFilter.new(term.strip!, true).create_filter,
                                   attributes: %w( cn displayname mail psadminarea psdepartment ),
                                   return_result: true) # was size: 200
      end
    end
    if ldap_records.present?
      LdapResult.new(ldap_record: ldap_records,
                     attribute_map: LdapResultsMap::AUTOCOMPLETE_LDAP_MAP[:map],
                     defaults:  LdapResultsMap[:defaults]).map_directory_info
    else
      if conn.get_operation_result.message == "Size Limit Exceeded"
        return []
      else
        raise ResultError, conn.get_operation_result.message
      end
    end
  end

  def exists?(psu_access_id)
    retrieve(psu_access_id).present?

    result = nil
    with_connection do |conn|
      3.times || !result.nil? do
        result = conn.search(base: ldap_configuration['base'], filter: Net::LDAP::Filter.eq('uid', psu_access_id))
        # break if result
      end
      if result.nil?
        Rails.logger.warn "No LDAP entry found for initial lookup of #{psu_access_id.inspect}"
        raise ResultError, conn.get_operation_result.message
      end
    end
    result.present?
  end

  def retrieve(psu_access_id)
    return {} if string_has_wildcard_character? psu_access_id
    ldap_record = directory_lookup('uid', psu_access_id)
    mapped_attributes = LdapResult.new(ldap_record: ldap_record,
                                       attribute_map: LdapResultsMap::AUTHOR_LDAP_MAP).map_directory_info
    return {} if mapped_attributes.nil? || mapped_attributes.empty?

    mapped_attributes.first
  end

  def authors_confidential_status(this_access_id)
    pshold = get_ldap_attribute(this_access_id, 'psconfhold')
    ActiveModel::Type::Boolean.new.cast(pshold.downcase)
  end

  def get_psu_id_number(this_access_id)
    attrs = ['psidn']
    with_connection do |connection|
      3.times || !attrs.empty? do
        attrs = connection.search(base: ldap_configuration['base'], filter: Net::LDAP::Filter.eq('uid', this_access_id), attributes: attrs)
        # break unless attrs == []
      end
      raise ResultError, connection.get_operation_result.message if attrs.nil?
      return ' ' if attrs.empty?
      psuid = attrs.first[:psidn].first
      psuid
    end
  end

  private

    def ldap_configuration
      # Only ever read this once.
      @ldap_configuration ||= YAML.load_file('config/ldap.yml')[Rails.env].freeze
    end

    def directory_lookup(query_type, search_string)
      attrs = []
      with_connection do |conn|
        3.times || !attrs.empty do
          attrs = conn.search(base: ldap_configuration['base'], filter: Net::LDAP::Filter.eq(query_type, search_string), attributes: attrs)
          # break unless attrs == []
        end

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

    def term_is_valid?(term)
      term.present? && term =~ /^[a-z '\-]+$/i
    end
end
