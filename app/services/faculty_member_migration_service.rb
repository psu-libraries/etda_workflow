class FacultyMemberMigrationService
  def migrate_faculty_members
    LdapUniversityDirectory.new.with_connection do |connection|
      CommitteeMember.find_each do |member|
        member_id = member.access_id
        faculty_member = FacultyMember.find_by(webaccess_id: member_id)
        # Temporarily backfill after running. move results back into unless block. Remove faculty_member.update
        results = retrieve(connection, member_id, 'uid')
        results = search_by_cn(member, connection) if results.blank?
        faculty_member.update(college: results[:college]) if faculty_member.present? && results.present? && results[:primary_affiliation] != 'MEMBER'
        faculty_member = FacultyMember.find_or_create_by(faculty_member_attrs(results)) if !faculty_member && (results.present? && results[:primary_affiliation] != 'MEMBER')
        member.update(faculty_member_id: faculty_member.id) if faculty_member.present?
      rescue StandardError => e
        Rails.logger.error e.message
      end
    end
  end

  private

    def faculty_member_attrs(ldap_result)
      { first_name: ldap_result[:first_name],
        middle_name: ldap_result[:full_name].split(' ').length == 3 ? ldap_result[:full_name].split(' ')[1].gsub(/[[:punct:]]/, '') : '',
        last_name: ldap_result[:last_name],
        department: ldap_result[:dept],
        webaccess_id: ldap_result[:access_id],
        college: ldap_result[:college] }
    end

    def search_by_cn(member, connection)
      common_suffixes_prefixes = [
        'Ph.D.',
        ', Ph.D.',
        ', Ph D',
        ', PhD',
        'Ph D',
        'PhD',
        'M.D.',
        ', Jr.',
        ', Jr',
        'Jr.',
        'Jr',
        'Dr .',
        'Dr,',
        'Dr.',
        'Drs',
        'Dr'
      ]
      name = member.name
      regex = Regexp.new(common_suffixes_prefixes.join('|'))
      clean_name = name.gsub(regex, '')
      result = retrieve(connection, clean_name, 'cn')
      if result.blank?
        split_name = clean_name.split(' ')
        if split_name.length == 3
          split_name.delete_at(1)
          nomiddle_name = split_name.join(' ')
          result = retrieve(connection, nomiddle_name, 'cn')
        end
      end
      result
    end

    # TODO: This method is nearly identical to ConfidentialHoldUpdateService#ldap_result_connected
    # Refactor these methods into a single method within LdapUniversityDirectory
    def retrieve(connection, value, attribute)
      attrs = connection.search(base: ldap_base,
                                filter: Net::LDAP::Filter.eq(attribute, value), attributes: [])
      mapped_attributes = LdapResult.new(ldap_record: attrs,
                                         attribute_map: LdapResultsMap::FACULTY_LDAP_MAP).map_directory_info
      return {} if mapped_attributes.blank?

      mapped_attributes.first
    end

    def ldap_base
      Rails.application.config_for(:ldap)['base']
    end
end
