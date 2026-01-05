class PdfDownloadWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'pdf_download'

  def perform(final_submission_file, url)
    PdfDownloadService.new(final_submission_file, url).call
  end
end
