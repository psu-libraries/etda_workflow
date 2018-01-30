require 'partner'
class Legacy::Importer
  def initialize(records_to_import)
    @display_logger = Logger.new(STDOUT)
    @import_logger = Logger.new("log/#{current_partner.id}_workflow_import.log")
    @records_to_import = records_to_import
    @original_count = @records_to_import.count.to_s
    @count = 0
  end

  def migrate_authors
    @import_logger.info "Legacy authors read: #{@original_count}"
    @records_to_import.each do |legacy_author|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} authors" if interval(10)
      Author.new(id: legacy_author['id'],
                 access_id: legacy_author['access_id'],
                 first_name: legacy_author['first_name'],
                 last_name: legacy_author['last_name'],
                 middle_name: legacy_author['middle_name'],
                 alternate_email_address: legacy_author['alternate_email_address'],
                 psu_email_address: legacy_author['psu_email_address'],
                 phone_number: legacy_author['phone_number'],
                 address_1: legacy_author['address_1'],
                 address_2: legacy_author['address_2'],
                 city: legacy_author['city'],
                 state: legacy_author['state'],
                 zip: legacy_author['zip'],
                 country: legacy_author['country'],
                 is_alternate_email_public: legacy_author['is_alternate_email_public'],
                 created_at: legacy_author['created_at'],
                 updated_at: legacy_author['updated_at'],
                 remember_created_at: legacy_author['remember_created_at'],
                 sign_in_count: legacy_author['sign_in_count'],
                 current_sign_in_at: legacy_author['current_sign_in_at'],
                 current_sign_in_ip: legacy_author['current_sign_in_ip'],
                 last_sign_in_ip: legacy_author['last_sign_in_ip'],
                 last_sign_in_at: legacy_author['last_sign_in_at'],
                 legacy_id: legacy_author['legacy_id'],
                 psu_idn: legacy_author['psu_idn']).save(validate: false)
    end
    @count
  end

  def migrate_submissions
    @import_logger.info "Legacy submissions read: #{@original_count}"
    @records_to_import.each do |legacy_submission|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} submissions" if interval 10
      Submission.new(id: legacy_submission['id'],
                     author_id: legacy_submission['author_id'],
                     program_id: legacy_submission['program_id'],
                     degree_id: legacy_submission['degree_id'],
                     semester: legacy_submission['semester'],
                     year: legacy_submission['year'],
                     created_at: legacy_submission['created_at'],
                     updated_at: legacy_submission['updated_at'],
                     status: legacy_submission['status'],
                     title: legacy_submission['title'],
                     format_review_notes: legacy_submission['format_review_notes'],
                     final_submission_notes: legacy_submission['final_submission_notes'],
                     defended_at: legacy_submission['defended_at'],
                     abstract: legacy_submission['abstract'],
                     access_level: legacy_submission['access_level'],
                     has_agreed_to_terms: legacy_submission['has_agreed_to_terms'],
                     committee_provided_at: legacy_submission['committee_provided_at'],
                     format_review_files_uploaded_at: legacy_submission['format_review_files_uploaded_at'],
                     format_review_rejected_at: legacy_submission['format_review_rejected_at'],
                     format_review_approved_at: legacy_submission['format_review_approved_at'],
                     final_submission_files_uploaded_at: legacy_submission['final_submission_files_uploaded_at'],
                     final_submission_rejected_at: legacy_submission['final_submission_rejected_at'],
                     final_submission_approved_at: legacy_submission['final_submission_approved_at'],
                     released_for_publication_at: legacy_submission['released_for_publication_at'],
                     released_metadata_at: legacy_submission['released_metadata_at'],
                     legacy_id: legacy_submission['legacy_id'],
                     final_submission_legacy_id: legacy_submission['final_submission_legacy_id'],
                     final_submission_legacy_old_id: legacy_submission['final_submission_legacy_old_id'],
                     format_review_legacy_id:  legacy_submission['format_review_legacy_id'],
                     format_review_legacy_old_id:  legacy_submission['format_review_legacy_old_id'],
                     admin_notes: legacy_submission['admin_notes'],
                     is_printed: legacy_submission['is_printed'],
                     allow_all_caps_in_title: legacy_submission['allow_all_caps_in_title'],
                     public_id: legacy_submission['public_id'],
                     format_review_files_first_uploaded_at: legacy_submission['format_review_files_first_uploaded_at'],
                     final_submission_files_first_uploaded_at: legacy_submission['final_submission_files_first_uploaded_at'],
                     lion_path_degree_code: legacy_submission['lion_path_degree_code'],
                     restricted_notes: legacy_submission['restricted_notes']).save(validate: false)
    end
    @count
  end

  def migrate_committee_members
    @import_logger.info "Legacy committee_members read: #{@original_count}"
    @records_to_import.each do |legacy_committee_member|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} committee_members" if interval 10
      CommitteeMember.new(id: legacy_committee_member['id'],
                          submission_id: legacy_committee_member['submission_id'],
                          committee_role_id: legacy_committee_member['committee_role_id'],
                          name: legacy_committee_member['name'],
                          email: legacy_committee_member['email'],
                          legacy_id: legacy_committee_member['legacy_id'],
                          is_required: legacy_committee_member['is_required'],
                          created_at: legacy_committee_member['created_at'],
                          updated_at: legacy_committee_member['updated_at']).save(validate: false)
    end
    @count
  end

  def migrate_degree_types
    @import_logger.info "Legacy degree types read: #{@original_count}"
    @records_to_import.each do |legacy_degree_type|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} degree_types"
      DegreeType.new(id: legacy_degree_type['id'],
                     name: legacy_degree_type['name'],
                     slug: legacy_degree_type['slug']).save(validate: false)
    end
    @count
  end

  def migrate_degrees
    @import_logger.info "Legacy degrees read: #{@original_count}"
    @records_to_import.each do |legacy_degree|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} degrees" if interval 10
      Degree.new(id: legacy_degree['id'],
                 name: legacy_degree['name'],
                 description: legacy_degree['description'],
                 is_active: legacy_degree['is_active'],
                 created_at: legacy_degree['created_at'],
                 updated_at: legacy_degree['updated_at'],
                 legacy_id: legacy_degree['legacy_id'],
                 legacy_old_id: legacy_degree['legacy_old_id'],
                 degree_type_id: legacy_degree['degree_type_id']).save(validate: false)
    end
    @count
  end

  def migrate_programs
    @import_logger.info "Legacy programs read: #{@original_count}"
    @records_to_import.each do |legacy_program|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} programs" if interval 10
      Program.new(id: legacy_program['id'],
                  name: legacy_program['name'],
                  created_at: legacy_program['created_at'],
                  updated_at: legacy_program['updated_at'],
                  legacy_id: legacy_program['legacy_id'],
                  legacy_old_id: legacy_program['legacy_old_id'],
                  is_active: legacy_program['is_active']).save(validate: false)
    end
    @count
  end

  def migrate_keywords
    @import_logger.info "Legacy keywords read: #{@original_count}"
    @records_to_import.each do |legacy_keyword|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} keywords" if interval 10
      Keyword.new(id: legacy_keyword['id'],
                  submission_id: legacy_keyword['submission_id'],
                  created_at: legacy_keyword['created_at'],
                  updated_at: legacy_keyword['updated_at'],
                  legacy_id: legacy_keyword['legacy_id'],
                  word: legacy_keyword['word']).save(validate: false)
    end
    @count
  end

  def migrate_final_submission_files
    @import_logger.info "Legacy final_submission_files read: #{@original_count}"
    @records_to_import.each do |legacy_final_submission_file|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} final_submission_files" if interval 10
      FinalSubmissionFile.new(id: legacy_final_submission_file['id'],
                              submission_id: legacy_final_submission_file['submission_id'],
                              created_at: legacy_final_submission_file['created_at'],
                              updated_at: legacy_final_submission_file['updated_at'],
                              legacy_id: legacy_final_submission_file['legacy_id'],
                              asset: legacy_final_submission_file['asset']).save(validate: false)
    end
    @count
  end

  def migrate_format_review_files
    @import_logger.info "Legacy format_review_files read: #{@original_count}"
    @records_to_import.each do |legacy_format_review_file|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} format_review_files" if interval 10
      FormatReviewFile.new(id: legacy_format_review_file['id'],
                           submission_id: legacy_format_review_file['submission_id'],
                           created_at: legacy_format_review_file['created_at'],
                           updated_at: legacy_format_review_file['updated_at'],
                           legacy_id: legacy_format_review_file['legacy_id'],
                           asset: legacy_format_review_file['asset']).save(validate: false)
    end
    @count
  end

  def migrate_committee_roles
    @import_logger.info "Legacy committee_roles read: #{@original_count}"
    @records_to_import.each do |legacy_committee_role|
      @count += 1
      @display_logger.info "Importing #{@count} of #{@original_count} committee_roles" if interval 10
      CommitteeRole.new(id: legacy_committee_role['id'],
                        name: legacy_committee_role['name'],
                        is_active: legacy_committee_role['is_active'],
                        num_required: legacy_committee_role['num_required'],
                        degree_type_id: legacy_committee_role['degree_type_id']).save(validate: false)
    end
    @count
  end

  def interval(val)
    (@count % val).zero?
  end
end
