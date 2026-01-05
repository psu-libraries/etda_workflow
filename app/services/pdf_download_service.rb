require 'open-uri'

class PdfDownloadService
  class DownloadError < StandardError; end

  def initialize(final_submission_file, url)
    @final_submission_file = submission_file
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
    downloaded_file&.close
    downloaded_file&.unlink
  end

  private def download_pdf
    uri = URI.parse(@url)
    raise DownloadError, "URL does not point to a PDF" unless uri.path.end_with?('.pdf')

    io = URI.open(uri, "rb") { |remote| remote.read }

    tmp = Tempfile.new([File.basename(uri.path, ".pdf"), ".pdf"])
    tmp.binmode
    tmp.write(io)
    tmp.rewind

    # This is the metadata that Carrier Wave is expecting
    tmp.define_singleton_method(:original_filename) { File.basename(uri.path) }
    tmp.define_singleton_method(:content_type)       { "application/pdf" }
    rescue OpenURI::HTTPError => e
      raise DownloadError, "Failed to download PDF (#{e.message})"
    rescue SocketError, Errno::ECONNREFUSED => e
      raise DownloadError, "Network error while fetching PDF (#{e.message})"
    tmp
  end
end
