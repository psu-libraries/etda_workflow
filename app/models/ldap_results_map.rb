class LdapResultsMap
  AUTOCOMPLETE_LDAP_MAP = { map: { displayname: [:label, :value],
                                   mail: [:id],
                                   psadminarea: [:dept_admin],
                                   psdepartment: [:dept]
  }, defaults: { dept: 'Department not available', id: 'Email not available' } }

  AUTHOR_LDAP_MAP = { uid: [:access_id],
                      givenname: [:first_name, :middle_name],
                      sn: [:last_name],
                      postaladdress: [:address_1, :city, :state, :country, :zip],
                      telephonenumber: [:phone_number],
                      psmemberof: [:is_admin],
                      psidn: [:psu_idn] }

  COMMITTEE_LDAP_MAP = { map: { displayname: [:label, :value],
                                mail: [:id],
                                psadminarea: [:dept_admin],
                                psdepartment: [:dept]
  }, defaults: { dept: 'Department not available', id: 'Email not available' } }

  LDAP_RESULTS_MAP = {
    last_name: { method: :format_upcase, options: {} },
    name: { method: :format_upcase, options: {} },
    value: { method: :format_upcase, options: {} },
    label: { method: :format_upcase, options: {} },
    dept_admin: { method: :format_department_admin, options: {} },
    dept: { method: :format_department, options: {} },
    first_name: { method: :format_name, options: { idx: 0 } },
    middle_name: { method: :format_name, options: { idx: 1 } },
    phone_number: { method: :format_phone_number, options: {} },
    address_1: { method: :format_address_1, options: {} },
    city: { method: :format_city, options: {} },
    state: { method: :format_state, options: {} },
    country: { method: :format_country, options: {} },
    zip: { method: :format_zip, options: {} },
    is_admin: { method: :format_is_admin, options: {} },
    psuidn: { method: :format_psuidn, options: {} }
  }
end
