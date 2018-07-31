class UpdateSubmissionService
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
