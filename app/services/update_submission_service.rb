class UpdateSubmissionService
  def self.admin_update_submission(submission, current_remote_user, params)
    submission.update params
    submission.committee_members.each do |committee_member|
      committee_member.notes << "#{current_remote_user} changed 'status' to '#{committee_member.status}' at: #{DateTime.now}\n" if committee_member.saved_change_to_status?
      committee_member.notes << "#{current_remote_user} changed 'is_voting' to '#{committee_member.is_voting}' at: #{DateTime.now}\n" if committee_member.saved_change_to_is_voting?
    end
    submission.save!
  end

  def send_email(submission)
    # submission.update_attributes!(submission_params)
    return { error: false, msg: 'No updates required; access level did not change' } unless submission.access_level != submission.previous_access_level

    email = AccessLevelUpdatedEmail.new(Admin::SubmissionView.new(submission, nil))
    email.deliver
  end

  def solr_delta_update(submission)
    # this occurs each time a final submission is published or unpublished.
    # All editing to published submissions requires unpublish then publish so this includes metadata changes that must be reindexed
    results = SolrDataImportService.new.delta_import
    return results unless results[:error]

    { error: true, msg: "Error occurred during solr update for record: #{submission.id}, #{submission.author.last_name}, #{submission.author.first_name}" }
  end
end
