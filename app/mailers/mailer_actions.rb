module MailerActions
  def send_committee_review_requests(submission, committee_member)
    if committee_member.committee_member_token.present?
      special_committee_review_request(submission, committee_member).deliver
    else
      committee_member_review_request(submission, committee_member).deliver
    end
  end

  def send_committee_review_reminders(submission, committee_member)
    if committee_member.committee_member_token.present?
      special_committee_review_request(submission, committee_member).deliver
    else
      committee_member_review_reminder(submission, committee_member).deliver
    end
  end

  def send_nonvoting_approval_reminders(submission, committee_member)
    nonvoting_approval_reminder(submission, committee_member).deliver
  end

  def send_publication_release_messages(submission)
    release_for_publication(submission).deliver if submission.open_access?
    release_for_publication_metadata_only(submission).deliver unless submission.open_access?
  end

  def send_final_emails(submission)
    final_submission_approved(submission).deliver
  end

  def send_head_of_program_review_request(submission, approval_status)
    committee_member_review_request(submission, CommitteeMember.program_head(submission)).deliver unless approval_status.head_of_program_status == 'approved'
  end

  def send_committee_approved_email(submission)
    committee_approved(submission).deliver if submission.degree.degree_type.approval_configuration.email_authors
  end

  def send_committee_rejected_emails(submission)
    committee_rejected_admin(submission).deliver if submission.degree.degree_type.approval_configuration.email_admins
    committee_rejected_author(submission).deliver if submission.degree.degree_type.approval_configuration.email_authors
    committee_rejected_committee(submission).deliver
  end

  def send_pending_returned_emails(submission)
    pending_returned_author(submission).deliver
    pending_returned_committee(submission).deliver
  end

  def send_final_submission_approved_email(submission)
    final_submission_approved(submission).deliver
  end

  def send_final_submission_rejected_email(submission)
    final_submission_rejected(submission).deliver
  end

  def send_final_submission_received_email(submission)
    final_submission_received(submission).deliver
  end

  def send_format_review_received_email(submission)
    format_review_received(submission).deliver
  end
end
