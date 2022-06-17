class SolrSubmission
  def initialize(submission)
    @submission = submission
  end

  def field_semantics
    {
      year: 'year_isi',
      public_id: 'id',
      final_submission_files_uploaded_at: 'final_submission_files_uploaded_at_dtsi',
      # download_access_group_ssim # bl access control do we neeed?
      # read_access_group_ssim
      final_submission_legacy_old_id: 'db_legacy_old_id',
      final_submission_file_isim: 'final_submission_file_isim',
      file_name_ssim: 'file_name_ssim',
      author_name_tesi: 'author_name_tesi',
      author_last_name: ['last_name_ssi', 'last_name_tesi'],
      author_middle_name: ['middle_name_ssi'],
      author_first_name: 'first_name_ssi',
      degree_type_slug: ['degree_type_slug_ssi'],
      degree_type_name: ['degree_type_ssi'],
      legacy_id: 'db_legacy_id',
      program_name: ['program_name_tesi', 'program_name_ssi'],
      committee_member_names: ['committee_member_name_ssim', 'committee_member_name_tesim'],
      committee_member_emails: ['committee_member_email_ssim'],
      committee_member_and_role: ['committee_member_and_role_tesim', 'committee_member_role_ssim'],
      keyword_list: ['keyword_ssim', 'keyword_tesim'],
      title: ['title_ssi', 'title_tesi'],
      id: ['db_id'],
      access_level: 'access_level_ss',
      semester: 'semester_ssi',
      abstract: 'abstract_tesi',
      defended_at: 'defended_at_dtsi',
      released_metadata_at: 'released_metadata_at_dtsi',
      degree_name: ['degree_name_ssi'],
      degree_description: ['degree_description_ssi']
    }
  end

  def to_solr
    hash = {}
    field_semantics.each do |(key, values)|
      Array(values).each do |value|
        hash[value] = @submission.send(key)
      end
    end
    hash
  end
end
