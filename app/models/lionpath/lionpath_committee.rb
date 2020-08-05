class Lionpath::LionpathCommittee

  def import(row)
    this_submission = submission(row)
    return if this_submission.committee_members.present?

    factory = Lionpath::LionpathCommitteeFactory.new(row, this_submission)
    factory.create_member
  end

  private

  def submission(row)
    this_author = author(row)
    this_author.submissions.find{ |s| s.degree.degree_type.slug == 'dissertation' }
  end

  def author(row)
    Author.find_by(psu_idn: row['Student ID'])
  end
end
