class FacultyMemberMigrationService
  CommitteeMember.find_each do |member|
   member_id = member.access_id 
   faculty_member = FacultyMember.find_by(webaccess_id: member_id)
   unless faculty_member && 
    results = LdapUniversityDirectory.new.retrieve(member_id, 'uid', LdapResultsMap::LDAP_RESULTS_MAP)
    new_faculty_member = FacultyMember.new()
    end
  end
 
end


