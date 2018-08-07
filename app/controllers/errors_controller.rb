# frozen_string_literal: true

class ErrorsController < ApplicationController
  def render_500
    render template: '/error/500', layout: 'error', formats: %i[html json]
  end

  def render_404
    render template: '/error/404', layout: 'error', formats: %i[html json]
  end

  def render_401
    render template: '/error/401', layout: 'error', formats: %i[html json]
  end

  private

  def render_routing_error(exception)
    logger.error("Rendering 404 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/404', layout: "error", formats: %i[html json], status: :not_found
  end
end
