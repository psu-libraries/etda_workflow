class LionpathCommitteeCheckService
  class IncompleteLionpathCommittee < StandardError; end

  def self.check_submission(submission)
    return if !current_partner.graduate? || submission.lionpath_updated_at.blank? ||
              submission.degree_type.slug != 'dissertation' || submission.voting_committee_members.present?

    raise IncompleteLionpathCommittee, I18n.t("#{current_partner.id}.committee.list.dissertation.incomplete_error")
  end
end
