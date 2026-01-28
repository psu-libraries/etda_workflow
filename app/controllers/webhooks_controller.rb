# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request

  def auto_remediate
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

  def handle_remediation_results
    event_type = params[:event_type]
    job_data   = params[:job] || {}

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

    def authenticate_request
      secret = ExternalApp.pdf_accessibility_api.token

      token = request.headers['X-API-KEY'].to_s
      head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(token, secret)
    end

    def log_webhook_error(error)
      Rails.logger.error do
        "Webhook failed: #{error.class} - #{error.message}\n" \
        "#{error.backtrace.take(10).join("\n")}"
      end
    end

    def can_remediate?
      final_submission_file.pdf? &&
        final_submission_file.remediation_started_at.nil? &&
        final_submission_file.remediated_final_submission_file.blank?
    end

    def final_submission_file
      @final_submission_file ||= FinalSubmissionFile.find(params[:final_submission_file_id])
    end

    def handle_success(job_data)
      BuildRemediatedFileWorker.perform_async(job_data[:uuid], job_data[:output_url])
      render json: { message: 'Update successful' }, status: :ok
    rescue StandardError => e
      log_webhook_error(e)
      render json: { error: e.message }, status: :internal_server_error
    end

    def handle_failure(job_data)
      Rails.logger.error("Auto-remediation job failed: #{job_data[:processing_error_message]}")
      render json: { message: job_data[:processing_error_message] }, status: :ok
    end
end
