# frozen_string_literal: true

def mock_ldap_entry
  ldap_entry = [{ dn: ["uid=xxb13,dc=psu,dc=edu"],
                  objectclass: ["top", "PSUperson", "eduPerson", "inetOrgPerson",
                                "organizationalPerson", "person", "posixAccount"],
                  mail: ["xxb13@psu.edu"], uid: ["xxb13"], edupersonprincipalname: ["xxb13@psu.edu"],
                  fax: ["1 814 123-4567"], labeleduri: ["http://www.personal.psu.edu/xxb13/"],
                  title: ["SR RES PRGMR"], givenname: ["JONI LEE"], sn: ["BARNOFF"], psmaclabgid: ["5000"],
                  psmaclabhomedir: ["/Users/guest"], psdiridn: ["370080"], psuidnumber: ["33333"],
                  edupersonprimaryaffiliation: ["STAFF"], gidnumber: ["1000"], uidnumber: ["333333"],
                  cn: ["JONI LEE BARNOFF"], displayname: ["JONI LEE BARNOFF"], loginshell: ["/bin/bash"],
                  psmailid: ["xxb13@psu.edu"], telephonenumber: ["+1 814 123 4567"], psidn: ['999999999'],
                  psadminarea: ["INFORMATION TECH SERVICES"],
                  psmemberof: ["cn=staff.up.cis,dc=psu,dc=edu", "cn=psu.facstaff,dc=psu,dc=edu",
                               "cn=umg/psu.sas.etda-honors-admins,dc=psu,dc=edu",
                               "cn=umg/psu.sas.etda-graduate-admins,dc=psu,dc=edu",
                               "cn=umg/psu.etda_sset_admin_users,dc=psu,dc=edu",
                               "cn=umg/psu.dsrd.etda_milsch_admin_users,dc=psu,dc=edu"],
                  homedirectory: ["/pass/users/j/x/xxb13"], edupersonaffiliation: ["member", "staff"],
                  postaladdress: ["003E PATERNO LIBRARY$UNIVERSITY PARK$UNIVERSITY PARK, PA 16802 US"],
                  pscampus: ["UNIVERSITY PARK"], psofficeaddress: ["E-4 Paterno Library"],
                  psbusinessarea: ["ITS SERVICES & SOLUTIONS"], psmailbox: ["xxb13@ucs.psu.edu"],
                  psmailhost: ["ucs.psu.edu"] }]
  ldap_entry
end

def mock_ldap_list
  ldap_list = [@myhash = { dn: ["uid=xxb13,dc=psu,dc=edu"],
                           objectclass: ["top", "PSUperson", "eduPerson", "inetOrgPerson",
                                         "organizationalPerson", "person", "posixAccount"],
                           mail: ["xxb13@psu.edu"], uid: ["xxb13"], edupersonprincipalname: ["xxb13@psu.edu"],
                           fax: ["1 814 987-6543"], labeleduri: ["http://www.personal.psu.edu/xxb13/"],
                           title: ["SR RES PRGMR"], givenname: ["JONI LEE"], sn: ["BARNOFF"],
                           psmaclabgid: ["5"], psmaclabhomedir: ["/Users/guest"], psdiridn: ["000000"],
                           psuidnumber: ["556666"], edupersonprimaryaffiliation: ["STAFF"],
                           gidnumber: ["1000"], uidnumber: ["999999999"], cn: ["JONI LEE BARNOFF"],
                           displayname: ["JONI LEE BARNOFF"], loginshell: ["/bin/bash"], psmailid: ["xxb13@psu.edu"],
                           telephonenumber: ["+1 814 987 6543"], psadminarea: ["INFORMATION TECH SERVICES"],
                           psidn: ['9999999999'],
                           psmemberof: ["cn=staff.up.cis,dc=psu,dc=edu", "cn=psu.facstaff,dc=psu,dc=edu",
                                        "cn=umg/up.its.sas,dc=psu,dc=edu"], homedirectory: ["/pass/users/j/x/xxb13"],
                           edupersonaffiliation: ["member", "staff"],
                           postaladdress: ["003E PATERNO LIBRARY$UNIVERSITY PARK$UNIVERSITY PARK, PA 16802"],
                           pscampus: ["UNIVERSITY PARK"], psofficeaddress: ["E-4 Paterno Library"],
                           psbusinessarea: ["ITS SERVICES & SOLUTIONS"], psmailbox: ["xxb13@ucs.psu.edu"],
                           psmailhost: ["ucs.psu.edu"] },
               @myhash = { dn: ["uid=meb133,dc=psu,dc=edu"],
                           objectclass: ["top", "PSUperson", "eduPerson", "inetOrgPerson", "organizationalPerson",
                                         "person", "posixAccount"],
                           mail: ["abc123@psu.edu"], uid: ["abc123"], psmailbox: ["abc123@email.psu.edu"],
                           edupersonprincipalname: ["abc123@psu.edu"], givenname: ["ALFRED B"],
                           displayname: ["ALFRED B CUNNINGHAM"], sn: ["CUNNINGHAM"], cn: ["ALFRED B CUNNINGHAM"],
                           psmaclabgid: ["5000"], psmaclabhomedir: ["/Users/guest"],
                           telephonenumber: ["+1 814 555 5555"], psdiridn: ["1111111"], psuidnumber: ["77777"],
                           edupersonprimaryaffiliation: ["STAFF"], psbusinessarea: ["TECHNOLOGY"], gidnumber: ["1000"],
                           uidnumber: ["7777"], loginshell: ["/bin/bash"], psmailhost: ["email.psu.edu"],
                           psmemberof: ["cn=umg/up.ecs,dc=psu,dc=edu", "cn=psu.facstaff,dc=psu,dc=edu",
                                        "cn=umg/psu.drsd.etda_milsch_admin_users,dc=psu,dc=edu",
                                        "cn=umg/up.its.voipusers,dc=psu,dc=edu"],
                           homedirectory: ["/pass/users/a/b/abc123"],
                           psmailid: ["acunningham@psu.edu", "abc123@psu.edu"],
                           title: ["RES & DEV ENGR"], edupersonaffiliation: ["staff", "member"],
                           postaladdress: ["TSB BUILDING (SUPER ADVANCED TECHNOLOGIES)$UNIVERSITY PARK$STATE COLLEGE, PA 16801 US"],
                           pscampus: ["UNIVERSITY PARK"], psadminarea: ["RESEARCH- DEFENSE REL"] },
               @myhash = { dn: ["uid=rmb1,dc=psu,dc=edu"],
                           objectclass: ["top", "PSUperson", "eduPerson", "inetOrgPerson", "organizationalPerson",
                                         "person", "posixAccount"],
                           psofficephone: ["1-814-111-1111"], mail: ["rss321@psu.edu"], uid: ["rss321"],
                           edupersonprincipalname: ["rss321@psu.edu"], fax: ["1-814-111-1111"],
                           postaladdress: ["123 ABC AVE$STATE COLLEGE, PA 16801"], title: ["MACHO MAN"],
                           givenname: ["RANDY S"], displayname: ["RANDY SAVAGE"], sn: ["SAVAGE"],
                           cn: ["RANDY SAVAGE"], psmaclabgid: ["5000"], psmaclabhomedir: ["/Users/guest"],
                           telephonenumber: ["+1 814 111 1111"], psdiridn: ["9090909"], psuidnumber: ["99999"],
                           edupersonprimaryaffiliation: ["EMERITUS"], gidnumber: ["1000"], uidnumber: ["888888"],
                           loginshell: ["/bin/bash"], psmailbox: ["rmb100@email.psu.edu"],
                           psmailhost: ["email.psu.edu"], psmailid: ["rss321@psu.edu"],
                           psmemberof: ["cn=psu.adj_facstaff,dc=psu,dc=edu"], homedirectory: ["/pass/users/r/m/rmb1"],
                           edupersonaffiliation: ["emeritus", "member"] }]

  ldap_list
end

def create_author_from_ldap
  @ldap_info = LdapLookup.new(uid: 'xxb13', ldap_record: mock_ldap_entry.first)
  @ldap_info.map_author_attributes
  author = Author.create(@ldap_info.mapped_attributes)
  author
end

def create_admin_from_ldap
  @ldap_info = LdapLookup.new(uid: 'xxb13', ldap_record: mock_ldap_entry.first)
  @ldap_info.map_author_attributes
  admin = Admin.create(@ladp_info.mapped_attributes)
  admin
end

def create_committee_lookup_list
  @ldap_info = LdapLookup.new(uid: 'barnoff', ldap_record: mock_ldap_list)
end
