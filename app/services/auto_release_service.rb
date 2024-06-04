class AutoReleaseService
  def release
    submission_ids = Submission.ok_to_autorelease.collect(&:id)
    Submission.release_for_publication(submission_ids, DateTime.now.end_of_day, 'Release as Open Access')
  end

  def notify_author
    submissions = Submission.notify_author_of_upcoming_release
    submissions.each do |submission|
      WorkflowMailer.send_author_release_warning(submission)
    end
  end
end
