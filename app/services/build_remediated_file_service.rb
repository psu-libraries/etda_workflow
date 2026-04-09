# frozen_string_literal: true

class BuildRemediatedFileService
  class DownloadError < StandardError; end

  def initialize(final_submission_file, url)
    @final_submission_file = final_submission_file
    @url = url
  end

  def call
    remediated_pdf = Down.download(@url)
    Rails.logger.info("Creating a Remediated File with url #{@url}")
    if RemediatedFinalSubmissionFile.create!(
      asset: remediated_pdf,
      final_submission_file: @final_submission_file,
      submission_id: @final_submission_file.submission.id
    )
      SolrDataImportService.new.index_submission(@final_submission_file.submission, true)
    end
  rescue Down::Error => e
    Rails.logger.error("Failed to download PDF(#{e.message})")
  rescue SocketError, Errno::ECONNREFUSED => e
    Rails.logger.error("Failed to download PDF(#{e.message})")
  rescue StandardError => e
    Rails.logger.error("Error: #{e.message}")
  ensure
    remediated_pdf&.close
    remediated_pdf&.unlink
  end
end
