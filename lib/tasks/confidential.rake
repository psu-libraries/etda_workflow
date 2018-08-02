# frozen_string_literal: true

namespace :confidential do
  desc "check unpublished submissions to determine whether they should be flagged as confidential"
  task checker: :environment do
    puts 'Checking unreleased submissions for authors with confidential hold'
    directory = LdapUniversityDirectory.new
    Author.all.each do |author|
      next unless directory.exists? author.access_id
      author_confidential_hold = ConfidentialHoldUtility.new(author.access_id, author.confidential_hold)
      next unless author_confidential_hold.changed?
      # this will NOT send out emails; should emails go out for this?

      author.confidential_hold = author_confidential_hold.new_confidential_status
      author.confidential_hold_set_at = Time.zone.now
      author.save(validate: false)

      puts "Author record updated: #{author.access_id}, record_id: #{author.id}"
      update_authors_submissions(author)
    end
  end

  desc 'Report Authors with a confidential hold'
  task report: :environment do
    puts 'Reporting authors with a confidential hold'
    directory = LdapUniversityDirectory.new
    Author.all.each do |author|
      next unless directory.exists? author.access_id
      results = nil
      results = directory.retrieve(author.access_id, LdapResultsMap::AUTHOR_LDAP_MAP)
      next if results == {}
      printf("Author with id: %s %s has a confidential hold\n", author.id.to_s, author.access_id) if results[:confidential_hold] == true
    end
  end

  def update_authors_submissions(author)
    author.submissions.each do |submission|
      next unless submission.status_behavior.waiting_for_publication_release?
      submission.status = 'confidential hold embargo'
      submission.confidential_hold_embargoed_at = Time.zone.now
      submission.save validate: false
      puts "Submission moved from 'ready to be released' to embargoed: #{submission.id}, author: #{submission.author.access_id}"
    end
  end
end
