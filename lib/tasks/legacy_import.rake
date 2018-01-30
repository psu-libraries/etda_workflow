require 'mysql2'

namespace(:legacy) do
  namespace(:import) do
    @import_logger = Logger.new("log/#{EtdaUtilities::Partner.current.id}_workflow_import.log")

    desc "import legacy authors"
    task authors: :environment do
      exit if table_has_data?(Author)
      legacy_authors = legacy_database.query("SELECT * FROM authors")
      legacy_importer = Legacy::Importer.new(legacy_authors)
      final_count = legacy_importer.migrate_authors
      final_import_message(Author, final_count)
    end

    desc "import legacy submissions"
    task submissions: :environment do
      exit if table_has_data? Submission
      legacy_submissions = legacy_database.query("SELECT * FROM submissions")
      legacy_importer = Legacy::Importer.new(legacy_submissions)
      final_count = legacy_importer.migrate_submissions
      final_import_message(Submission, final_count)
    end

    desc "import committee_members"
    task committee_members: :environment do
      exit if table_has_data? CommitteeMember
      legacy_committee_members = legacy_database.query("SELECT * FROM committee_members")
      legacy_importer = Legacy::Importer.new(legacy_committee_members)
      final_count = legacy_importer.migrate_committee_members
      final_import_message(CommitteeMember, final_count)
    end

    desc "import degree_types"
    task degree_types: :environment do
      exit if table_has_data? DegreeType
      legacy_degree_types = legacy_database.query("SELECT * FROM degree_types")
      legacy_importer = Legacy::Importer.new(legacy_degree_types)
      final_count = legacy_importer.migrate_degree_types
      final_import_message(DegreeType, final_count)
    end

    desc "import committee_roles"
    task committee_roles: :environment do
      exit if table_has_data? CommitteeRole
      legacy_committee_roles = legacy_database.query("SELECT * FROM committee_roles")
      legacy_importer = Legacy::Importer.new(legacy_committee_roles)
      final_count = legacy_importer.migrate_committee_roles
      final_import_message(CommitteeRole, final_count)
    end

    desc "import degrees"
    task degrees: :environment do
      exit if table_has_data? Degree
      legacy_degrees = legacy_database.query("SELECT * FROM degrees")
      legacy_importer = Legacy::Importer.new(legacy_degrees)
      final_count = legacy_importer.migrate_degrees
      final_import_message(Degree, final_count)
    end

    desc "import programs"
    task programs: :environment do
      exit if table_has_data? Program
      legacy_programs = legacy_database.query("SELECT * FROM programs")
      legacy_importer = Legacy::Importer.new(legacy_programs)
      final_count = legacy_importer.migrate_programs
      final_import_message(Program, final_count)
    end

    desc "import keywords"
    task keywords: :environment do
      exit if table_has_data? Keyword
      legacy_keywords = legacy_database.query("SELECT * FROM keywords")
      legacy_importer = Legacy::Importer.new(legacy_keywords)
      final_count = legacy_importer.migrate_keywords
      final_import_message(Keyword, final_count)
    end

    desc "import format_review_files"
    task format_review_files: :environment do
      exit if table_has_data? FormatReviewFile
      legacy_format_review_files = legacy_database.query("SELECT * FROM format_review_files")
      legacy_importer = Legacy::Importer.new(legacy_format_review_files)
      final_count = legacy_importer.migrate_format_review_files
      final_import_message(FormatReviewFile, final_count)
    end

    desc "import final_submission_files"
    task final_submission_files: :environment do
      exit if table_has_data? FinalSubmissionFile
      legacy_final_submission_files = legacy_database.query("SELECT * FROM final_submission_files")
      legacy_importer = Legacy::Importer.new(legacy_final_submission_files)
      final_count = legacy_importer.migrate_final_submission_files
      final_import_message(FinalSubmissionFile, final_count)
    end

    desc "import entire Rails-4 ETDA database into Rails-5"
    task all_data: :environment do
      Rake::Task['legacy:import:authors'].invoke
      Rake::Task['legacy:import:degree_types'].invoke
      Rake::Task['legacy:import:committee_roles'].invoke
      Rake::Task['legacy:import:degrees'].invoke
      Rake::Task['legacy:import:programs'].invoke
      Rake::Task['legacy:import:submissions'].invoke
      Rake::Task['legacy:import:keywords'].invoke
      Rake::Task['legacy:import:final_submission_files'].invoke
      Rake::Task['legacy:import:format_review_files'].invoke
      Rake::Task['legacy:import:committee_members'].invoke
    end

    def legacy_database
      @client ||= Mysql2::Client.new(Rails.configuration.database_configuration['legacy_database_dev'])
    end

    def table_has_data?(this_model)
      return false if this_model.all.count.zero?
      @import_logger.info "Error:  #{this_model.name} contains data; quitting import"
      true
    end

    def final_import_message(this_model, final_import_count)
      @import_logger.info "Total #{this_model.table_name} created during migrate: #{final_import_count}"
      @import_logger.info "Actual database total: #{this_model.all.count} \n"
    end
  end
end
