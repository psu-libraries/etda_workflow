class Lionpath::LionpathCommittee
  def import(row)
    this_submission = submission(row)
    return if this_submission.blank? || this_submission.year < 2021

    if this_submission.committee_members.present?
      cm = this_submission.committee_members.find_by(access_id: row['Access ID'].downcase.to_s)
      if cm.present?
        cm.update committee_member_attrs(row)
        return
      end
    end
    CommitteeMember.create({ submission: this_submission }.merge(committee_member_attrs(row)))
  end

  private

  def committee_member_attrs(row)
    committee_role = CommitteeRole.find_by(code: row['Role'].to_s)
    {
      committee_role: committee_role,
      is_required: true,
      name: "#{row['First Name']} #{row['Last Name']}",
      email: "#{row['Access ID'].downcase}@psu.edu",
      access_id: row['Access ID'].downcase.to_s,
      is_voting: true,
      lionpath_updated_at: DateTime.now
    }
  end

  def submission(row)
    this_author = author(row)
    return if this_author.blank? || this_author.submissions.blank?

    this_author.submissions.find { |s| s.degree_type.slug == 'dissertation' }
  end

  def author(row)
    Author.find_by(psu_idn: row['Student ID'].to_s)
  end
end
