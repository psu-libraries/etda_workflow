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

    remediation_job_uuid = PdfRemediation::Client.new(download_url).request_remediation
    file.update_column(:remediation_job_uuid, remediation_job_uuid)
  end
end
