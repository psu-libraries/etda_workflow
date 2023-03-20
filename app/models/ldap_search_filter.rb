# frozen_string_literal: true

class LdapSearchFilter
  def initialize(term, restrict_to_non_member)
    @term = term
    @restrict_to_non_member = restrict_to_non_member
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
                           "#{search_words.join(' ')}*"
                         end

    ldap_name_attribute = search_words.count == 1 ? 'sn' : 'cn'
    search_string_filter = Net::LDAP::Filter.eq(ldap_name_attribute, ldap_search_string)

    if @restrict_to_non_member
      # faculty_filter = Net::LDAP::Filter.eq('edupersonprimaryaffiliation', "FACULTY")
      # staff_filter = Net::LDAP::Filter.eq('edupersonprimaryaffiliation', "STAFF")
      # faculty_staff_filter = Net::LDAP::Filter.intersect(faculty_filter, staff_filter) # yeah, we know

      Net::LDAP::Filter.join(combined_filter, search_string_filter)
    else
      search_string_filter
    end
  end

  private

    def faculty_staff_filter
      Net::LDAP::Filter.intersect(Net::LDAP::Filter.eq('edupersonprimaryaffiliation', 'FACULTY'), Net::LDAP::Filter.eq('edupersonprimaryaffiliation', 'STAFF'))
    end

    def emeritus_retired_filter
      Net::LDAP::Filter.intersect(Net::LDAP::Filter.eq('edupersonprimaryaffiliation', 'EMERITUS'), Net::LDAP::Filter.eq('edupersonprimaryaffiliation', 'RETIREE'))
    end

    def combined_filter
      Net::LDAP::Filter.intersect(faculty_staff_filter, emeritus_retired_filter)
    end
end
