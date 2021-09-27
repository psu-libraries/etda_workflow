class SeventhDayEvaluationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'committee_evaluations'

  def perform
  end
end
