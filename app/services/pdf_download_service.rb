# frozen_string_literal: true

class PdfDownloadService
  class DownloadError < StandardError; end

  def initialize(final_submission_file, url)
    @final_submission_file = final_submission_file
    @url = url
  end

  def call
    remediated_pdf = download_pdf
    RemediatedFinalSubmissionFile.create(
      asset: remediated_pdf,
      final_submission_file: @final_submission_file,
      submission_id: @final_submission_file.submission.id
    )
  ensure
    remediated_pdf&.close
    remediated_pdf&.unlink
  end

  private

    def download_pdf
      uri = URI.parse(@url)
      raise DownloadError, "URL does not point to a PDF" unless uri.path.end_with?('.pdf')

      Down.download(@url)
    rescue Down::Error => e
      raise DownloadError, "Failed to download PDF (#{e.message})"
    rescue SocketError, Errno::ECONNREFUSED => e
      raise DownloadError, "Network error while fetching PDF (#{e.message})"
    end
end
