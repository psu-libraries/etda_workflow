namespace :db_update do
  namespace(:dups) do
    # rails db_update:dups:fix_authors[legacy] or
    # rails db_update:dups:fix_authors[none, dry_run] --performs a dry run on the workflow database
  desc "remove duplicate author records from database; adding a second parameter, 'dry_run', will show results without updating the database."
    task :fix_authors, [:db, :dry_run] =>  :environment do |_task, args|
      puts "Removing duplicate authors #{Time.zone.now}" unless Rails.env.test?
      initialize_database(args.db) if args.db.present?
      dry_run = args.dry_run.present? ? true : false
      dup_list = get_dup_list
      if dup_list.nil?
        puts "No updates performed.  There are no duplicate authors in the database "
        exit 0
      end
      count = 0
      dup_list.each do |dup|
        aa = Author.where(access_id: dup.access_id)
        if aa.first.submissions.any? && aa.last.submissions.any?
          extra_author = nil
          puts "Both records have submissions and were not deleted:  #{aa.first.access_id}:  #{aa.first.id}  #{aa.last.id}"
          next
        end
        if aa.last.submissions.any?
          extra_author = aa.first
        elsif aa.first.submissions.any?
          extra_author = aa.last
        else !aa.first.submissions.any? && !aa.last.submissions.any?
          extra_author = aa.last
        end
        count += 1
        output = 'Deleted '
        output = "Dry Run (delete) - " if dry_run
        output += "#{extra_author.access_id} #{extra_author.id}"
        extra_author.destroy unless dry_run
        puts output
      end
      puts "Total authors deleted: #{count}"
    end
    # rails db_update:dups:list_authors[legacy] or
    # rails db_update:dups:list_authors[]
    desc "list duplicate author records in database "
    task :list_authors, [:db] =>  :environment do |_task, args|
      initialize_database(args.db) if args.db.present?
       dup_list = get_dup_list
      if dup_list.empty?
        puts "There are no duplicate authors in the database "
        exit 0
      end
      dup_list.each do |dup|
        aa = Author.where(access_id: dup.access_id)
        aa.each do |a|
          puts "Access_id: #{a.access_id}, Id: #{a.id}, Submission Count: #{a.submissions.count || 0}"
        end
      end
    end

    def get_dup_list
      # results = selected_database.query("SELECT ACCESS_ID FROM AUTHORS GROUP BY ACCESS_ID HAVING COUNT(*) > 1")
      Author.select(:access_id).group(:access_id).having("COUNT(*)>1")
    end

   def initialize_database(which_db)
      # use legacy database if it's included in the parameter list; otherwise use etda_workflow database
      if which_db == 'legacy'
        legacy_db = Rails.env.test? ? Rails.configuration.database_configuration['test_legacy_database'] : Rails.configuration.database_configuration[Rails.env]['legacy_database']
        ActiveRecord::Base.establish_connection(legacy_db)
      end
    end
  end
end