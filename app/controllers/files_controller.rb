class FilesController < ApplicationController
  def download_format_review
    file = FormatReviewFile.find(params[:id])
    authorize! :read, file
    send_file file.asset.path, disposition: :inline
    DownloadFileLog.save_download_details(file, request.remote_ip)
  end

  def download_final_submission
    file = FinalSubmissionFile.find(params[:id])
    authorize! :read, file
    send_file file.asset.path, disposition: :inline
    DownloadFileLog.save_download_details(file, request.remote_ip)
  end

  private

    def current_ability
      @current_ability ||= FileDownloadAbility.new(current_author)
    end
end
