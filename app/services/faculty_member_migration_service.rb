class FacultyMemberMigrationService
  def initialize
    @connection = LdapUniversityDirectory.new
  end

  def migrate_faculty_members
    CommitteeMember.find_each do |member|
      member_id = member.access_id
      faculty_member = FacultyMember.find_by(webaccess_id: member_id)
      unless faculty_member
        results = @connection.retrieve(member_id, 'uid', LdapResultsMap::FACULTY_LDAP_MAP)
        results ||= search_by_cn(member)
        faculty_member = FacultyMember.create(faculty_member_attrs(results)) if results.present? && results[:primary_affiliation] != 'MEMBER'
      end
      member.update(faculty_member_id: faculty_member.id) if faculty_member.present?
    rescue StandardError => e
      Rails.logger.error e.message
    end
  end

  private

    def faculty_member_attrs(ldap_result)
      { first_name: ldap_result[:first_name],
        middle_name: ldap_result[:middle_name],
        last_name: ldap_result[:last_name],
        department: ldap_result[:dept],
        webaccess_id: ldap_result[:access_id] }
    end

    def search_by_cn(member)
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
      result = @connection.retrieve(clean_name, 'cn', LdapResultsMap::FACULTY_LDAP_MAP)
      unless result
        split_name = clean_name.split(' ')
        if split_name.length == 3
          split_name = split_name.delete_at(1)
          nomiddle_name = split_name.join(' ')
          result = @connection.retrieve(nomiddle_name, 'cn', LdapResultsMap::FACULTY_LDAP_MAP)
        end
      end
      result
    end
end
