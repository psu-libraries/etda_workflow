require 'active_record/fixtures'

namespace :legacy do
  namespace :db do
    # these ':db' tasks populate a test legacy database that is used when testing the import tasks.
    def db_tables
      ['authors', 'degree_types', 'committee_roles', 'degrees', 'programs', 'submissions', 'keywords', 'final_submission_files', 'format_review_files', 'committee_members', 'invention_disclosures']
    end

    def current_config
      Rails.configuration.database_configuration['test_legacy_database']
    end

    desc 'Creates the legacy database in config/database.yml for the current RAILS_ENV'
    task 'create' => :environment do
      ActiveRecord::Tasks::DatabaseTasks.create current_config
    end

    desc 'Drops the legacy database in config/database.yml for the current RAILS_ENV'
    task 'drop' => :environment do
      ActiveRecord::Tasks::DatabaseTasks.drop current_config
    end

    desc 'load legacy fixtures'
    task 'test_fixtures:load': :environment do
      # abort('This task can only run in the TEST environment') unless Rails.env.test?
      ActiveRecord::Tasks::DatabaseTasks.drop current_config
      ActiveRecord::Tasks::DatabaseTasks.create current_config
      ActiveRecord::Tasks::DatabaseTasks.database_configuration = current_config
      db_tables.each do |table_name|
        ActiveRecord::Tasks::DatabaseTasks.structure_load(current_config, Rails.root.join('spec', 'fixtures', 'legacy', "#{table_name}.sql"))
      end
    end
  end

  # not needed?  Can import files directly from fixtures directory.
  # namespace :files do
  #   desc 'load legacy test files'
  #   task 'test_files:load': :environment do
  #     source_path = Rails.root.join('spec', 'fixtures', 'legacy', 'files')
  #     final_destination_path = 'tmp/fixtures/final_submission_files'
  #     FileUtils.mkpath(source_path)
  #     FileUtils.mkpath(final_destination_path)
  #     FileUtils.mkpath('tmp/fixtures/format_review_files')
  #     FileUtils.copy_entry("spec/fixtures/legacy/files/FormatUnderReview.pdf", 'tmp/fixtures/format_review_files/FileFormatUnderReview.pdf')
  #     FileUtils.copy_entry("#{source_path}/OpenAccess.pdf", "#{final_destination_path}/OpenAccess.pdf")
  #     FileUtils.copy_entry("#{source_path}/RestrictedInstitutionThesis.pdf", "#{final_destination_path}/RestrictedInstitutionThesis.pdf")
  #     FileUtils.copy_entry("#{source_path}/RestrictedThesis.pdf", "#{final_destination_path}/RestrictedThesis.pdf")
  #   end
  # end
end
