class Lionpath::LionpathCommittee
  def import(row)
    this_submission = submission(row)
    return if invalid_submission?(this_submission)

    committee_role = CommitteeRole.find_by(code: row['Role'].to_s)
    if this_submission.committee_members.present?
      cm = this_submission.committee_members.find_by(access_id: row['Access ID'].downcase,
                                                     committee_role:)
      if cm.present?
        if self.class.external_ids.include? cm.access_id.downcase
          cm.update external_to_psu_id: row['Access ID'].downcase
          return
        end

        committee_member_update(cm, row, committee_role)
        return
      end

      cm_external = this_submission.committee_members.find_by(external_to_psu_id: row['Access ID'].downcase,
                                                              committee_role:)
      return if cm_external.present?
    end

    CommitteeMember.create(
      { submission: this_submission,
        email: "#{row['Access ID'].downcase}@psu.edu" }.merge(committee_member_attrs(row, committee_role))
    )
  end

  def self.external_ids
    # These Access IDs indicate a committee member is external to PSU
    %w[mgc25 mgc29 mgc30 mgc31].freeze
  end

  private

    def committee_member_update(committee_member, row, committee_role)
      committee_member.update committee_member_attrs(row, committee_role) unless
          committee_member.submission.status_behavior.beyond_waiting_for_final_submission_response_rejected?
    end

    def committee_member_attrs(row, committee_role)
      hash = {
        committee_role:,
        is_required: true,
        name: if special_member?(row)
                "#{row['Special Member First Name'].titleize} #{row['Special Member Last Name'].titleize}"
              else
                "#{row['First Name']} #{row['Last Name']}"
              end,
        access_id: row['Access ID'].downcase.to_s,
        is_voting: true,
        lionpath_updated_at: DateTime.now
      }
      hash[:external_to_psu_id] = row['Access ID'].downcase if self.class.external_ids.include?(row['Access ID'].downcase)
      hash
    end

    def special_member?(row)
      !row['Special Member First Name'].nil? && !row['Special Member Last Name'].nil?
    end

    def submission(row)
      this_author = author(row)
      return if this_author.blank? || this_author.submissions.blank?

      this_author.submissions
                 .joins(degree: [:degree_type])
                 .find_by("degree_types.slug = 'dissertation' AND submissions.lionpath_updated_at IS NOT NULL")
    end

    def invalid_date?(submission)
      submission.preferred_year < 2021
    end

    def invalid_submission?(submission)
      submission.blank? || submission.lionpath_updated_at.blank? || invalid_date?(submission)
    end

    def author(row)
      Author.find_by(access_id: row['Student Campus ID'].downcase.to_s)
    end
end
