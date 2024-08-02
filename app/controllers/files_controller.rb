class FilesController < ApplicationController
  def download_format_review
    file = FormatReviewFile.find(params[:id])
    authorize! :read, file, file.submission
    send_file file.current_location, disposition: :inline
    # DownloadFileLog.save_download_details(file, request.remote_ip)
  end

  def download_final_submission
    file = FinalSubmissionFile.find(params[:id])
    authorize! :read, file, file.submission
    send_file file.current_location, disposition: :inline
    # DownloadFileLog.save_download_details(file, request.remote_ip)
  end

  def download_admin_feedback
    file = AdminFeedbackFile.find(params[:id])
    authorize! :read, file, file.submission
    send_file file.current_location, disposition: :inline
    # DownloadFileLog.save_download_details(file, request.remote_ip)
  end

  private

    def files_params
      params.require(:file).permit([:asset, :asset_cache, :feedback_type, :id, :_destroy])
    end
end
