class LionpathExportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'lionpath_exports'

  def perform(submission_id)
    submission = Submission.find(submission_id)
    Lionpath::LionpathExport.new(submission).call
  end
end
