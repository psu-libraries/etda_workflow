class MockUniversityDirectory
  AUTHOR_LDAP_MAP = LdapResultsMap::AUTHOR_LDAP_MAP

  KNOWN_ACCESS_IDS = %w(
    saw140
    jxb13
    amg32
  )

  COMMITTEE_LDAP_MAP = LdapResultsMap::COMMITTEE_LDAP_MAP

  # Return an array of tuples that are suitable for returning
  # to a jQuery autocomplete widget.
  def autocomplete(search_string, _only_faculty_staff: true)
    case search_string
    when /(joni)/i
      [
        { id: 'jxd2@psu.edu', label: 'Joni Davis', value: 'Joni Davis' },
        { id: 'jxb13@psu.edu', label: 'Joni Barnoff', value: 'Joni Barnoff' }
      ]
    when /(scott)/i
      [
        { id: 'sar3@psu.edu', label: 'Scott Rogers', value: 'Scott Rogers' },
        { id: 'saw140@psu.edu', label: 'Scott Woods', value: 'Scott Woods' }
      ]
    else
      []
    end
  end

  def exists?(psu_access_id)
    KNOWN_ACCESS_IDS.include?(psu_access_id)
  end

  def retrieve(psu_access_id)
    case psu_access_id
    when /(jxb13)/i
      { access_id: 'jxb13', first_name: 'Joni', middle_name: 'Lee',
        last_name: 'Barnoff', address_1: 'TSB Building',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '555-555-5555',
        country: 'US', is_admin: true, psu_idn: '999999999' }
    when /(amg32)/i
      { access_id: 'amg32', first_name: 'Andrew', middle_name: 'Michael',
        last_name: 'Gearhart', address_1: 'Pattee Library',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '814-867-5373',
        country: 'US', is_admin: true, psu_idn: '987654321' }
    when /(saw140)/i
      { access_id: 'saw140', first_name: 'Scott', middle_name: 'Aaron',
        last_name: 'Woods', address_1: 'Allenway Bldg.',
        city: 'State College', state: 'PA',
        zip: '16801', phone_number: '666-666-6666',
        country: 'US', is_admin: true, psu_idn: '981818181' }
    when /(xxb13)/i
      { access_id: 'testid', first_name: 'testfirst', middle_name: 'testmiddle',
        last_name: 'testlast', address_1: 'Anywhere',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '555-555-5555',
        country: 'US', is_admin: true, psu_idn: '999999999' }
    else
      []
    end
  end

  def populate_with_ldap_attributes(psu_access_id)
    case psu_access_id
    when /(xxb13)/i
      { access_id: 'xxb13', first_name: 'Test', middle_name: 'Person',
        last_name: 'Rails', address_1: 'TSB Building',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '555-555-5555',
        country: 'US', is_admin: true, psu_idn: '999999999' }
    when /(admin123)/i
      { access_id: 'admin123', first_name: 'Test', middle_name: 'Admin',
        last_name: 'Person', address_1: 'TSB Building',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '555-555-5555',
        country: 'US', is_admin: true, psu_idn: '988888888' }
    else
      {}
    end
  end

  def get_psu_id_number(_psu_access_id)
    '999999999'
  end
end
