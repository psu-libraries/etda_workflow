# frozen_string_literal: true

class LdapResult
  include ActiveModel::Model
  include ActiveModel::AttributeMethods

  attr_accessor :ldap_record
  attr_accessor :attribute_map
  attr_accessor :defaults
  attr_accessor :us_state
  attr_accessor :department

  UPCASE_NAME_LIST = /\b(iii|ii|iv)\b/i
  UPCASE_DEPT_LIST = /\b(its|ids|arl|psu)\b/i

  def map_directory_info
    mapped_attributes = []
    ldap_record.first(20).each do |ldap_entry|
      entry_attributes = {}
      self.us_state = ''
      self.department = ''
      attribute_map.each do |ldap_key, mapped_keys|
        res = map_ldap_attribute(ldap_key, mapped_keys, ldap_entry)
        res.each do |key, val|
          entry_attributes.store(key, val)
        end
      end
      # trying to figure out why dept will not display
      # it works on first required committee member and all add-on members
      mapped_attributes << entry_attributes.except(:dept_admin)
    end
    mapped_attributes || []
  end

  def map_ldap_attribute(ldap_key, mapped_keys, ldap_entry)
    res = {}
    ldap_value = ldap_entry[ldap_key]
    mapped_keys.each do |k|
      if ldap_value.nil? || ldap_value.blank?
        res[k] = default(k)
      else
        new_ldap_value = k == :administrator ? ldap_value : ldap_value.first
        res[k] = map_value(new_ldap_value, k)
      end
    end
    res
  end

  def map_value(ldap_value, new_key)
    method = LdapResultsMap::LDAP_RESULTS_MAP[new_key]
    return ldap_value if method.blank?
    method(method[:method]).call(ldap_value, method[:options])
  end

  def default(k)
    return '' if defaults.nil?
    defaults[k]
  end

  private

  def format_upcase(ldap_value, _options)
    # split on hypens and apostrophes to correctly capitalize names like:  Smith-Miller, O'Malley, etc.
    # #gsub to correctly capitalize roman numerals following last name
    tmp_str = ldap_value.split(/-|'/)
    tmp_chrs = ldap_value.scan(/-|'/)
    tmp_str.map(&:titleize).zip(tmp_chrs).join.gsub(UPCASE_NAME_LIST, &:upcase)
  end

  def format_department_admin(ldap_value, _options)
    self.department = ldap_value.titleize
  end

  def format_department(ldap_value, _options)
    (ldap_value.titleize || department).to_s.gsub(UPCASE_DEPT_LIST, &:upcase)
  end

  def format_name(ldap_value, options)
    names = ldap_value.split(/\W+/)
    names[options[:idx]].titleize unless names.count <= options[:idx]
  end

  def format_phone_number(ldap_value, _options)
    ldap_value.remove('+1 ').tr(' ', '-')
  end

  def format_address_1(ldap_value, _options)
    ldap_value.titleize.split('$').first || ''
  end

  def format_city(ldap_value, _options)
    res = (ldap_value.titleize.split('$').last || '').split(',')
    res[0] || ''
  end

  def format_state(ldap_value, _options)
    state = (ldap_value.split('$').last || '').split(',').last || ''
    state = state.split(' ').first unless state.nil?
    state = state.upcase if state
    self.us_state = state
  end

  def format_country(_ldap_value, _options)
    '' # currently country is not included in LDAP but keep this column here for future use
  end

  def format_zip(ldap_value, _options)
    ldap_value.split(' ').last || ''
  end

  def format_administrator(ldap_value, _options)
    user_in_admin_group? ldap_value
  end

  def format_psuidn(ldap_value, _options)
    ldap_value
  end

  def format_confidential(ldap_value, _options)
    ActiveModel::Type::Boolean.new.cast(ldap_value.downcase)
  end

  def user_in_admin_group?(ldap_value)
    return true if ldap_value.include?("cn=umg/psu.sas.etda-#{current_partner.id}-admins,dc=psu,dc=edu") || ldap_value.include?("cn=umg/psu.dsrd.etda_#{current_partner.id}_admin_users,dc=psu,dc=edu")
    false
  end
end
