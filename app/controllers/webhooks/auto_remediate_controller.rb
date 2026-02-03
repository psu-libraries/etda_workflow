# frozen_string_literal: true

class Webhooks::AutoRemediateController < Webhooks::BaseController
  def create
    if params[:final_submission_file_id].present?
      final_submission.final_submission_files.each do |file|
        if file.can_remediate?
          file.update_column(:remediation_started_at, Time.current)
          AutoRemediateWorker.perform_async(file.id)
        end
      end
      head :ok
    else
      head :bad_request
    end
  rescue StandardError => e
    log_webhook_error(e)
    head :internal_server_error
  end

  private

    def authenticate_request
      secret = ExternalApp.etda_explore.token

      token = request.headers['X-API-KEY'].to_s
      head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(token, secret)
    end

    def final_submission
      requested_file = FinalSubmissionFile.find(params[:final_submission_file_id])
      @final_submission ||= requested_file.submission
    end
end
