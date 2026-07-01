# frozen_string_literal: true

class LdapSearchFilter
  ELIGIBLE_AFFILIATIONS = %w[FACULTY STAFF EMERITUS RETIREE].freeze

  def initialize(term)
    @term = term
  end

  def create_filter
    filters = access_ids.map { |id| uid_filter(id) }
    return nil if filters.empty?

    filters.reduce(:|)
  end

  private

    def access_ids
      people_search_results.filter_map do |person|
        person.user_id if eligible_affiliation?(person)
      end
    end

    def people_search_results
      # There is no way to filter by affiliation in the PSU Identity Services API,
      # so keep `size` large and filter out 'STUDENT', 'MEMBER', etc. in code
      PsuIdentity::SearchService::Client
        .new
        .search(text: @term, size: 50, active: true, service_account: false)
    rescue PsuIdentity::SearchService::Error => e
      Rails.logger.error("Error searching PSU Identity Service: #{e.message}")
      []
    end

    def eligible_affiliation?(person)
      ELIGIBLE_AFFILIATIONS.any? { |affiliation| person.affiliation.include?(affiliation) }
    end

    def uid_filter(access_id)
      Net::LDAP::Filter.eq('uid', access_id)
    end
end
