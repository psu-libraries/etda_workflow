class AutoReleaseService
  def release
    submission_ids = Submission.ok_to_autorelease.collect(&:id)
    Submission.release_for_publication(submission_ids, DateTime.now.end_of_day, 'Release as Open Access')
  end

  def notify_author
    submissions = Submission.release_warning_needed?
    submissions.each do |submission|
      submission.create_extension_token
      WorkflowMailer.send_author_release_warning(submission)
      submission.update(author_release_warning_sent_at: DateTime.now)
    end
  end
end
