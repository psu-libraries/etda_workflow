# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Configure ActiveJob with SideKiq
Rails.application.config.active_job.queue_adapter = :sidekiq