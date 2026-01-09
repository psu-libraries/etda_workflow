# frozen_string_literal: true

class BuildRemediatedFileWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(job_uuid, output_url)
    final_submission_file = FinalSubmissionFile.where(:job_uuid => job_uuid).first
    BuildRemediatedFileService.new(final_submission_file, output_url).call
  end
end
