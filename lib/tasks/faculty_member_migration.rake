desc 'Migrating faculty member table'
  task faculty_member_migration: :environment do
    FacultyMemberMigrationService.new.migrate_faculty_members()
  end