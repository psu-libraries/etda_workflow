# frozen_string_literal: true

class LdapResultsMap
  AUTOCOMPLETE_LDAP_MAP = { map: { displayname: %i[label value],
                                   mail: [:id],
                                   psadminarea: [:dept_admin],
                                   psbusinessarea: [:dept] }, defaults: { dept: 'Department not available', id: 'Email not available' } }.freeze

  AUTHOR_LDAP_MAP = { uid: [:access_id],
                      givenname: %i[first_name middle_name],
                      sn: [:last_name],
                      postaladdress: %i[address_1 city state zip country],
                      telephonenumber: [:phone_number],
                      psidn: [:psu_idn],
                      psconfhold: [:confidential_hold] }.freeze

  ADMIN_LDAP_MAP = { uid: [:access_id],
                     givenname: [:first_name],
                     sn: [:last_name],
                     postaladdress: [:address_1],
                     telephonenumber: [:phone_number],
                     psmemberof: [:administrator],
                     psidn: [:psu_idn] }.freeze

  COMMITTEE_LDAP_MAP = { uid: [:access_id],
                         displayname: %i[label value],
                         mail: [:id],
                         psadminarea: [:dept_admin],
                         psdepartment: [:dept] }.freeze

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
    zip: { method: :format_zip, options: {} },
    country: { method: :format_country, options: {} },
    administrator: { method: :format_administrator, options: {} },
    psuidn: { method: :format_psuidn, options: {} },
    confidential_hold: { method: :format_confidential, options: {} }
  }.freeze

  FACULTY_LDAP_MAP = { uid: [:access_id],
                       givenname: [:first_name],
                       cn: [:full_name],
                       sn: [:last_name],
                       psdepartment: [:dept],
                       edupersonprimaryaffiliation: [:primary_affiliation] }.freeze
end
