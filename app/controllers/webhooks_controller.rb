# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def auto_remediate
    Rails.logger.info("Webhook auto_remediate received: #{request.raw_post}")
    head :no_content
  end
end
