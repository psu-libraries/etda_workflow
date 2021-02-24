class LionpathCommitteeCheckService
  class IncompleteLionpathCommittee < StandardError; end

  def self.check_submission(submission)
    return if (!current_partner.graduate? || submission.lionpath_updated_at.blank? ||
        submission.degree_type.slug != 'dissertation') && (submission.voting_committee_members.count > 0)

    raise IncompleteLionpathCommittee, 'Your committee is not complete.  Please complete your committee in LionPATH.'
  end
end