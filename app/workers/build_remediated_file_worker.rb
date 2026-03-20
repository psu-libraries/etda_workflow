# frozen_string_literal: true

class BuildRemediatedFileWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'auto_remediate_in'

  def perform(remediation_job_uuid, output_url)
    Rails.logger.info("Remediation Results Remediation Job Uuid: #{event_type}")
    Rails.logger.info("Remediation Results Output Url: #{job_data}")
    final_submission_file = FinalSubmissionFile.where(remediation_job_uuid:).first
    Rails.logger.info("Remediation Results Final Submission File: #{final_submission_file}")
    BuildRemediatedFileService.new(final_submission_file, output_url).call
  end
end
