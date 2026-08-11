# frozen_string_literal: true

class Webhooks::RemediationResultsController < Webhooks::BaseController
  def create
    event_type = remediation_results_params[:event_type]
    job_data   = remediation_results_params[:job] || {}

    case event_type
    when 'job.succeeded'
      handle_success(job_data)
    when 'job.failed'
      handle_failure(job_data)
    else
      Rails.logger.error("Unknown event type received: #{event_type}")
      render json: { error: 'Unknown event type' }, status: :bad_request
    end
  rescue StandardError => e
    log_webhook_error(e)
    head :internal_server_error
  end

  private

    RESET_REMEDIATION_ERRORS = [
      'Owner must belong to a unit to validate page quota',
      'must be greater than 0',
      'exceeds the unit\'s overall page limit',
      'exceeds the user\'s daily page limit',
      'must be an integer'
    ].freeze

    def authenticate_request
      secret = ExternalApp.pdf_accessibility_api.token

      token = request.headers['X-API-KEY'].to_s
      head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(token, secret)
    end

    def handle_success(job_data)
      BuildRemediatedFileWorker.perform_async(job_data[:uuid], job_data[:output_url])
      Rails.logger.info("Auto-remediation job succeeded: #{job_data[:uuid]}")
      render json: { message: 'Update successful' }, status: :ok
    rescue StandardError => e
      log_webhook_error(e)
      render json: { error: e.message }, status: :internal_server_error
    end

    def handle_failure(job_data)
      error_message = job_data[:processing_error_message]

      Rails.logger.error("Auto-remediation job failed: #{error_message}")

      if RESET_REMEDIATION_ERRORS.any? { |message| error_message.include?(message) }
        final_submission_file = FinalSubmissionFile.find_by(remediation_job_uuid: job_data[:uuid])

        final_submission_file&.update_columns(
          remediation_started_at: nil,
          remediation_job_uuid: nil
        )
      end

      render json: { message: error_message }, status: :ok
    end

    def remediation_results_params
      params.permit(
        :event_type,
        job: [:uuid, :status, :output_url, :processing_error_message]
      )
    end
end
