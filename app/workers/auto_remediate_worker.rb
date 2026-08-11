# frozen_string_literal: true

class AutoRemediateWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'auto_remediate_out'

  def perform(final_submission_file_id)
    file = FinalSubmissionFile.find(final_submission_file_id)
    # There is no public download URL within ETDA Workflow, so we construct one
    # that points to the ETDA Explore application.  This is somewhat brittle since
    # it needs to know the URL structure of ETDA Explore, without any shared code.
    download_url = "#{EtdUrls.new.explore}/files/final_submissions/#{file.id}"

    remediation_job_uuid = begin
      PdfRemediation::Client.new(download_url).request_remediation
    rescue PdfRemediation::Client::InvalidFileURL
      raise
    rescue StandardError => e
      # Errors at this stage are likely to be transient (except InvalidFileURL), so we reset the remediation_started_at timestamp so that the file can be retried later.
      Rails.logger.error("AutoRemediateWorker remediation request failed for FinalSubmissionFile #{final_submission_file_id}: #{e.class}: #{e.message}")
      file.update_column(:remediation_started_at, nil)
      raise
    end

    file.update_column(:remediation_job_uuid, remediation_job_uuid)
  end
end
