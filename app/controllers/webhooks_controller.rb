# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request

  def auto_remediate
    if params[:final_submission_file_id].present?
      AutoRemediateWorker.perform_async(params[:final_submission_file_id])
      render json: { status: 'accepted' }, status: :ok
    else
      head :bad_request
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

    def authenticate_request
      secret = ENV['AUTO_REMEDIATE_WEBHOOK_SECRET']
      if secret.blank?
        Rails.logger.error('AUTO_REMEDIATE_WEBHOOK_SECRET not set')
        return head :unauthorized
      end

      token = request.headers['X-API-KEY'].to_s
      head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(token, secret)
    end
end
