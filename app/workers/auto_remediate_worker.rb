# frozen_string_literal: true

class AutoRemediateWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'auto_remediate_out'

  def perform(final_submission_file_id)
    file = FinalSubmissionFile.find(final_submission_file_id)

    remediation_job_uuid = PdfRemediation::Client.new(file.file_url).request_remediation
    file.update(remediation_job_uuid: remediation_job_uuid)
  end
end
