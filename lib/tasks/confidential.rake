# frozen_string_literal: true

namespace :confidential do

  desc 'Report Authors with a confidential hold'
  task report: :environment do
    puts 'Reporting authors with a confidential hold'
    directory = LdapUniversityDirectory.new
    Author.all.each do |author|
      next unless directory.exists? author.access_id
      results = nil
      results = directory.retrieve(author.access_id, 'uid', LdapResultsMap::AUTHOR_LDAP_MAP)
      next if results == {}
      printf("Author with id: %s %s has a confidential hold\n", author.access_id, author.psu_email_address) if results[:confidential_hold] == true
    end
  end

  desc 'Update authors that have a confidential hold status in ldap'
  task update: :environment do
    start = Time.now
    ConfidentialHoldUpdateService.update_all
    puts "Process completed in #{(Time.now - start)} sec."
  end
end
