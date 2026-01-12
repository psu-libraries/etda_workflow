# frozen_string_literal: true

class AutoRemediateWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(final_submission_file_id)
    final_submission_file = FinalSubmissionFile.find(final_submission_file_id)
    PdfRemediation::Client.new.remediate(final_submission_file.file.path)
  rescue StandardError => e
    Rails.logger.error do
      "AutoRemediateWorker failed for FinalSubmissionFile ID #{final_submission_file_id}: " \
      "#{e.class} - #{e.message}\n" \
      "#{e.backtrace.take(10).join("\n")}"
    end
  end
end
