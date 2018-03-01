class UpdateSubmissionService
  def self.call(submission)
    # submission.update_attributes!(submission_params)
    return if submission.access_level == submission.previous_access_level
    # email = AccessLevelUpdatedEmail.new(SubmissionDecorator.new(submission, nil))
    # email.deliver
    # if submission.access_level > submission.previous_access_level
    # SolrDataImportService.delta_import
    # end
    # end
  end
end
