# frozen_string_literal: true

class MockUniversityDirectory
  AUTHOR_LDAP_MAP = ::LdapResultsMap::AUTHOR_LDAP_MAP

  ADMIN_LDAP_MAP = ::LdapResultsMap::ADMIN_LDAP_MAP

  COMMITTEE_LDAP_MAP = ::LdapResultsMap::COMMITTEE_LDAP_MAP

  AUTOCOMPLETE_LDAP_MAP = ::LdapResultsMap::AUTOCOMPLETE_LDAP_MAP

  KNOWN_ACCESS_IDS = %w[
    ajk5603
    amg32
    xxb13
    conf123
    dmc186
  ].freeze

  # Return an array of tuples that are suitable for returning
  # to a jQuery autocomplete widget.
  def autocomplete(search_string, _only_faculty_staff: true)
    case search_string
    when /(alex)/i
      unless Rails.env.test?
        [
          { id: 'ajk5603@psu.edu', label: 'Alex Kiessling', value: 'Alex Kiessling', dept: 'University Libraries' }
        ]
      end
      [
        { id: 'ajk5603@psu.edu', label: 'Alex James Kiessling', value: 'Alex James Kiessling', dept: 'University Libraries' }
      ]
    when /(john)/i
      [
        { id: 'jkl123@psu.edu', label: 'John Smith', value: 'John Smith' },
        { id: 'Email not available', label: 'John Fred Williams', value: 'John Fred Williams', dept: 'Department not available' }
      ]
    when /Professor Buck Murphy/i
      [
        { id: 'buck@hotmail.com', label: 'Professor Buck Murphy', value: 'Professor Buck Murphy', dept: 'University Libraries' }
      ]
    else
      []
    end
  end

  def exists?(psu_access_id)
    KNOWN_ACCESS_IDS.include?(psu_access_id)
  end

  def retrieve(input_string, query_type, attributes_map)
    result = get_id_info(input_string, query_type)
    return result if result.empty?

    if attributes_map == ADMIN_LDAP_MAP
      result.except(:middle_name, :city, :state, :zip, :country, :confidential_hold)
    else
      result.except(:administrator, :site_administrator)
    end
  end

  def retrieve_committee_access_id(psu_email)
    return nil if psu_email.blank?

    return psu_email.gsub('@psu.edu', '').strip if psu_email.match?(/.*@psu.edu/)

    return 'pbm123' if psu_email == 'buck@hotmail.com'

    nil
  end

  def get_psu_id_number(_psu_access_id)
    '999999999'
  end

  def authors_confidential_status(psu_access_id)
    results = retrieve(psu_access_id, 'uid', AUTHOR_LDAP_MAP)
    return false if results.empty?

    results[:confidential_hold]
  end

  def in_admin_group?(this_access_id)
    result = get_id_info(this_access_id, 'uid')
    return false if result.blank?

    result[:administrator] || false
  end

  def get_id_info(query_string, query_type)
    if query_type == 'uid'
      case query_string
      when /(ajk5603)/i
        { access_id: 'ajk5603', first_name: 'Alex', middle_name: 'James',
          last_name: 'Kiessling', address_1: 'Pattee Library',
          city: 'University Park', state: 'PA',
          zip: '16802', phone_number: '555-555-5555',
          country: 'US', psu_idn: '999999999', confidential_hold: true,
          administrator: true, site_administrator: true }
      when /(dmc186)/i
        { access_id: 'dmc186', first_name: 'Daniel', middle_name: 'Michael',
          last_name: 'Coughlin', address_1: 'University Libraries',
          city: 'University Park', state: 'PA',
          zip: '16802', phone_number: '555-555-5555',
          country: 'US', psu_idn: '999999999', confidential_hold: false,
          administrator: true, site_administrator: true }
      when /(amg32)/i
        { access_id: 'amg32', first_name: 'Andrew', middle_name: 'Michael',
          last_name: 'Gearhart', address_1: 'Pattee Library',
          city: 'University Park', state: 'PA',
          zip: '16802', phone_number: '555-555-5555',
          country: 'US', psu_idn: '999999999', confidential_hold: false,
          administrator: true, site_administrator: true }
      when /(xxb13)/i
        { access_id: 'testid', first_name: 'testfirst', middle_name: 'testmiddle',
          last_name: 'testlast', address_1: 'Anywhere',
          city: 'University Park', state: 'PA',
          zip: '16802', phone_number: '555-555-5555',
          country: 'US', confidential_hold: false, psu_idn: '999999999',
          administrator: true, site_administrator: true }
      when /(conf123)/i
        { access_id: 'conf123', first_name: 'Confidential', middle_name: 'X.',
          last_name: 'Student', address_1: 'I cannot tell you', city: 'Secret', state: 'PA',
          zip: '16801', phone_number: '111-111-1111', psu_idn: '977777777',
          confidential_hold: true, administrator: false, site_administrator: true }
      else
        []
      end
    else
      { access_id: 'testid', first_name: 'testfirst', middle_name: 'testmiddle',
        last_name: 'testlast', address_1: 'Anywhere',
        city: 'University Park', state: 'PA',
        zip: '16802', phone_number: '555-555-5555',
        country: 'US', confidential_hold: false, psu_idn: '999999999',
        administrator: true, site_administrator: true }
    end
  end

  def with_connection
    yield FakeConnection.new
  end

  class FakeConnection
    def search(*)
      "Hello!"
    end
  end
end
