class AutoReleaseService
  def release
    submission_ids = Submission.ok_to_autorelease.collect(&:id)
    Submission.release_for_publication(submission_ids, DateTime.now.end_of_day, 'Release as Open Access')
  end

end
