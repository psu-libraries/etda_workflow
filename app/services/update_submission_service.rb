class UpdateSubmissionService
  def self.call(submission)
    # submission.update_attributes!(submission_params)

    return unless submission.access_level != submission.previous_access_level
    email = AccessLevelUpdatedEmail.new(SubmissionDecorator.new(submission, nil))
    email.deliver
    # SolrDataImportService.delta_import if new submission.current_access_level.to_i > submission.previous_access_level.to_i
  end
end
