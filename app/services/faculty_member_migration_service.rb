class FacultyMemberMigrationService
  def self.migrate_faculty_members()
    count = 0
    connection = LdapUniversityDirectory.new
    CommitteeMember.find_each do |member|
      count += 1
      begin 
        member_id = member.access_id 
        faculty_member = FacultyMember.find_by(webaccess_id: member_id)
        unless faculty_member
          results = connection.retrieve(member_id, 'uid', LdapResultsMap::FACULTY_LDAP_MAP)
          faculty_member = FacultyMember.create(faculty_member_attrs(results)) if results.present? && results[:primary_affiliation] != 'MEMBER'
        end
        if faculty_member.present?
          member.update(faculty_member_id: faculty_member.id)
        end
      rescue StandardError => e
        puts member.id
        puts member.to_json
        puts e
      end
      puts count if count % 10 == 0
    end
  end
  # Making collection of ppl without access ids
  private

  def self.faculty_member_attrs(ldap_result)
    {first_name: ldap_result[:first_name], 
    middle_name: ldap_result[:middle_name],
    last_name: ldap_result[:last_name],
    department: ldap_result[:department],
    webaccess_id: ldap_result[:access_id]} 
  end
end