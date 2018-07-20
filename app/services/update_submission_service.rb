class UpdateSubmissionService
  def self.call(submission)
    # submission.update_attributes!(submission_params)

    return { error: false } unless submission.access_level != submission.previous_access_level
    email = AccessLevelUpdatedEmail.new(Admin::SubmissionView.new(submission, nil))
    email.deliver
    # this occurs each time a final submisison is published or unpublished.
    # All editing to published submissions requires unpublish then publish so this includes metadata changes that must be reindexed
    SolrDataImportService.new.delta_import if submission.current_access_level.to_i > submission.previous_access_level.to_i
  end
end
