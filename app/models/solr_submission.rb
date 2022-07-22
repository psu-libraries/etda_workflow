class SolrSubmission < SimpleDelegator
  def __setobj__(object)
    raise ArgumentError, "Object is not a Submission" unless object.is_a? Submission

    super
  end

  def to_solr
    hash = {}
    field_semantics.each do |(key, values)|
      Array(values).each do |value|
        hash[value] = send(key)
      end
    end
    hash
  end

  private

    def field_semantics
      {
        year: 'year_isi',
        public_id: 'id',
        final_submission_files_uploaded_at_dtsi: 'final_submission_files_uploaded_at_dtsi',
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
        defended_at_dtsi: 'defended_at_dtsi',
        released_metadata_at_dtsi: 'released_metadata_at_dtsi',
        degree_name: ['degree_name_ssi'],
        degree_description: ['degree_description_ssi']
      }
    end

    def final_submission_files_uploaded_at_dtsi
      convert_to_utc(:final_submission_files_uploaded_at)
    end

    def released_metadata_at_dtsi
      convert_to_utc(:released_metadata_at)
    end

    def defended_at_dtsi
      convert_to_utc(:defended_at)
    end

    def convert_to_utc(attr)
      return send(attr).getutc if send(attr).respond_to?(:getutc)

      send(attr)&.to_datetime&.getutc
    end

    def committee_member_and_role
      member_roles = []
      committee_members.each do |member|
        member_and_role = "#{member.name}, #{member.committee_role.name}"
        member_roles.append(member_and_role)
      end
      member_roles
    end

    def committee_member_emails
      emails = []
      committee_members.each do |member|
        emails.append(member.email)
      end
      emails
    end

    def committee_member_names
      names = []
      committee_members.each do |member|
        names.append(member.name)
      end
      names
    end

    def author_name_tesi
      "#{author.last_name}, #{author.first_name} #{author.middle_name}"
    end

    def file_name_ssim
      files = []
      final_submission_files.each do |file|
        files.append(file[:asset])
      end
      files
    end

    def final_submission_file_isim
      files = []
      final_submission_files.each do |file|
        files.append(file[:id])
      end
      files
    end
end
