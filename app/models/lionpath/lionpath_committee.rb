class Lionpath::LionpathCommittee
  def import(row)
    this_submission = submission(row)
    return if this_submission.lionpath_upload_finished_at.present? ||
              this_submission.status_behavior.beyond_collecting_committee? ||
              this_submission.created_at < DateTime.yesterday

    CommitteeMember.create({ submission: this_submission }.merge(committee_member_attrs(row)))
  end

  private

  def committee_member_attrs(row)
    committee_role = CommitteeRole.find_by(code: row['Role'])
    {
      committee_role: committee_role,
      is_required: true,
      name: "#{row['First Name']} #{row['Last Name']}",
      email: "#{row['Access ID'].downcase}@psu.edu",
      access_id: row['Access ID'].downcase.to_s,
      is_voting: true,
      lionpath_uploaded_at: DateTime.now
    }
  end

  def submission(row)
    this_author = author(row)
    this_author.submissions.find { |s| s.degree.degree_type.slug == 'dissertation' }
  end

  def author(row)
    Author.find_by(psu_idn: row['Student ID'])
  end
end
