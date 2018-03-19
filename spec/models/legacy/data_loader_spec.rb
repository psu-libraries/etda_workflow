# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Legacy::Importer do
  legacy_data = LegacyLoadHelper.new
  new_database = LegacyDatabaseHelper.new

  before do
    CommitteeRole.all.each(&:destroy)
    DegreeType.all.each(&:destroy)
  end

  it 'creates database from legacy records' do
    legacy_authors = legacy_data.author
    expect(Author.all.count).to eq(0)
    importer = described_class.new(legacy_authors)
    importer.migrate_authors
    check_fields(new_database.author_columns, legacy_authors, Author)
    # degree_type
    expect(DegreeType.all.count).to eq(0)
    legacy_degree_types = legacy_data.degree_type
    importer = described_class.new(legacy_degree_types)
    importer.migrate_degree_types
    check_fields(new_database.degree_type_columns, legacy_degree_types, DegreeType)
    # committee_roles
    expect(CommitteeRole.all.count).to eq(0)
    legacy_committee_roles = legacy_data.committee_role
    importer = described_class.new(legacy_committee_roles)
    importer.migrate_committee_roles
    check_fields(new_database.committee_role_columns, legacy_committee_roles, CommitteeRole)
    # degree records
    expect(Degree.all.count).to eq(0)
    legacy_degrees = legacy_data.degree
    importer = described_class.new(legacy_degrees)
    importer.migrate_degrees
    check_fields(new_database.degree_columns, legacy_degrees, Degree)
    # program records
    expect(Program.all.count).to eq(0)
    legacy_programs = legacy_data.program
    importer = described_class.new(legacy_programs)
    importer.migrate_programs
    check_fields(new_database.program_columns, legacy_programs, Program)
    # submission records
    expect(Submission.all.count).to eq(0)
    legacy_submissions = legacy_data.submission
    importer = described_class.new(legacy_submissions)
    importer.migrate_submissions
    check_fields(new_database.submission_columns, legacy_submissions, Submission)
    expect(Submission.all.count).to eql(legacy_submissions.count)
    # format_review_file records
    expect(FormatReviewFile.all.count).to eq(0)
    legacy_format_review_files = legacy_data.format_review_file
    importer = described_class.new(legacy_format_review_files)
    importer.migrate_format_review_files
    check_fields(new_database.format_review_file_columns, legacy_format_review_files, FormatReviewFile)
    expect(FormatReviewFile.all.count).to eq(legacy_format_review_files.count)
    # final_submission_file records
    expect(FinalSubmissionFile.all.count).to eq(0)
    legacy_final_submission_files = legacy_data.final_submission_file
    importer = described_class.new(legacy_final_submission_files)
    importer.migrate_final_submission_files
    check_fields(new_database.final_submission_file_columns, legacy_final_submission_files, FinalSubmissionFile)
    expect(FinalSubmissionFile.all.count).to eql(legacy_final_submission_files.count)
    # creates keywords
    expect(Keyword.all.count).to eq(0)
    legacy_keywords = legacy_data.keyword
    importer = described_class.new(legacy_keywords)
    importer.migrate_keywords
    check_fields(new_database.keyword_columns, legacy_keywords, Keyword)
    expect(Keyword.all.count).to eql(legacy_keywords.count)
    # committee_members
    expect(CommitteeMember.all.count).to eq(0)
    legacy_committee_members = legacy_data.committee_member
    importer = described_class.new(legacy_committee_members)
    importer.migrate_committee_members
    check_fields(new_database.committee_member_columns, legacy_committee_members, CommitteeMember)
    expect(CommitteeMember.all.count).to eql(legacy_committee_members.count)
    # invention disclosures
    expect(InventionDisclosure.all.count).to eq(0)
    legacy_inventions = legacy_data.invention_disclosure
    importer = described_class.new(legacy_inventions)
    importer.migrate_invention_disclosures
    check_fields(new_database.invention_disclosure_columns, legacy_inventions, InventionDisclosure)
    expect(InventionDisclosure.all.count).to eql(legacy_inventions.count)
  end

  # check if data created in database matches the fixture legacy data
  def check_fields(database_fields, legacy_data, object)
    legacy_data.each do |data|
      obj = object.find(data['id'])
      database_fields.each do |field|
        puts field.inspect
        expect(data[field]).to eql(obj.send(field)) unless field == 'asset'
      end
    end
  end
end
