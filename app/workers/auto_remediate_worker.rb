# frozen_string_literal: true

class AutoRemediateWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(final_submission_file_id)
  end
end
