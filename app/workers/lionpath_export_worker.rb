class LionpathExportWorker
  QUEUE = 'lionpath_exports'.freeze
  include Sidekiq::Worker
  sidekiq_options queue: QUEUE

  def perform(submission_id)
    submission = Submission.find(submission_id)
    Lionpath::LionpathExport.new(submission).call
  end
end
