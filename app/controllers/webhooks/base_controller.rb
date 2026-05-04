# frozen_string_literal: true

class Webhooks::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request

  private

    def log_webhook_error(error)
      Rails.logger.error do
        "Webhook failed: #{error.class} - #{error.message}\n" \
        "#{error.backtrace.take(10).join("\n")}"
      end
    end

    def authenticate_request
      raise NotImplementedError, 'You must implement this method in your controller subclass'
    end
end
