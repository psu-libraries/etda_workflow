# frozen_string_literal: true

class Webhooks::AutoRemediateController < Webhooks::BaseController
  def create
    if params[:final_submission_file_id].present?
      if can_remediate?
        final_submission_file.update_column(:remediation_started_at, Time.current)
        AutoRemediateWorker.perform_async(params[:final_submission_file_id])
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

    def can_remediate?
      final_submission_file.pdf? &&
        final_submission_file.remediation_started_at.nil? &&
        final_submission_file.remediated_final_submission_file.blank?
    end

    def final_submission_file
      @final_submission_file ||= FinalSubmissionFile.find(params[:final_submission_file_id])
    end
end
