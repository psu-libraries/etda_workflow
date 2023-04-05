class FacultyMemberMigrationService
  def migrate_faculty_members()
    CommitteeMember.find_each do |member|
      member_id = member.access_id 
      faculty_member = FacultyMember.find_by(webaccess_id: member_id)
      unless faculty_member
        results = LdapUniversityDirectory.new.retrieve(member_id, 'uid', LdapResultsMap::FACULTY_LDAP_MAP)
        FacultyMember.create(faculty_member_attrs(results)) if results.present? && results[:primary_affiliation] != 'MEMBER'
      # else
        # Link to existing faculty member
      end
    end
  end

  private

  def faculty_member_attrs(ldap_result)
    {first_name: ldap_result[:first_name], 
    middle_name: ldap_result[:middle_name],
    last_name: ldap_result[:last_name],
    department: ldap_result[:department],
    webaccess_id: ldap_result[:access_id]} 
  end
end

# LdapUniversityDirectory.new.retrieve('ajk5603', 'uid', LdapResultsMap::FACULTY_LDAP_MAP)
