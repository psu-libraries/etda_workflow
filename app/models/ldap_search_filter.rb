class LdapSearchFilter
  def initialize(term, only_faculty_staff)
    @term = term
    @only_faculty_staff = only_faculty_staff
  end

  def create_filter
    search_words = @term.split(/\s+/)
    ldap_search_string = case search_words.count
                         when 1
                           # Assume they're in the process of typing the last name.
                           "#{search_words[0]}*"
                         when 2
                           # Assume that they're typing first and last name, but a middle
                           # name might be present.
                           "#{search_words[0]}* #{search_words[1]}*"
                         else
                           # Once they're on their third word, assume that they're going
                           # for an exact match, but still typing the last word.
                           search_words.join(" ") + "*"
                         end

    ldap_name_attribute = search_words.count == 1 ? 'sn' : 'cn'
    search_string_filter = Net::LDAP::Filter.eq(ldap_name_attribute, ldap_search_string)

    if @only_faculty_staff
      # faculty_filter = Net::LDAP::Filter.eq('edupersonprimaryaffiliation', "FACULTY")
      # staff_filter = Net::LDAP::Filter.eq('edupersonprimaryaffiliation', "STAFF")
      # faculty_staff_filter = Net::LDAP::Filter.intersect(faculty_filter, staff_filter) # yeah, we know
      filter = Net::LDAP::Filter.join(faculty_staff_filter, search_string_filter)
    else
      filter = search_string_filter
    end
    filter
  end

  private

    def faculty_staff_filter
      Net::LDAP::Filter.intersect(Net::LDAP::Filter.eq('edupersonprimaryaffiliation', 'FACULTY'), Net::LDAP::Filter.eq('edupersonprimaryaffiliation', 'STAFF'))
    end
end
