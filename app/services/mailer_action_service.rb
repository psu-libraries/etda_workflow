module MailerActionService
  def send_committee_review_requests(submission, committee_member)
    if committee_member.committee_member_token.present?
      WorkflowMailer.special_committee_review_request(submission, committee_member).deliver
    else
      WorkflowMailer.committee_member_review_request(submission, committee_member).deliver
    end
  end

  def send_committee_review_reminders(submission, committee_member)
    if committee_member.committee_member_token.present?
      WorkflowMailer.special_committee_review_request(submission, committee_member).deliver
    else
      WorkflowMailer.committee_member_review_reminder(submission, committee_member).deliver
    end
  end

  def send_publication_release_messages(submission)
    WorkflowMailer.release_for_publication(submission).deliver if submission.open_access?
    WorkflowMailer.release_for_publication_metadata_only(submission).deliver unless submission.open_access?
  end

  def send_final_emails(submission)
    WorkflowMailer.committee_approved(submission).deliver if submission.degree.degree_type.approval_configuration.email_authors && !current_partner.honors?
    WorkflowMailer.final_submission_approved(submission).deliver if current_partner.honors?
  end

  def send_head_of_program_review_request(submission, submission_status)
    WorkflowMailer.committee_member_review_request(submission, CommitteeMember.head_of_program(id)).deliver unless submission_status.head_of_program_status == 'approved'
  end

  def send_committee_approved_email(submission)
    WorkflowMailer.committee_approved(submission).deliver if submission.degree.degree_type.approval_configuration.email_authors && current_partner.honors?
  end

  def send_committee_rejected_emails(submission)
    WorkflowMailer.committee_rejected_admin(submission).deliver if submission.degree.degree_type.approval_configuration.email_admins
    WorkflowMailer.committee_rejected_author(submission).deliver if submission.degree.degree_type.approval_configuration.email_authors
  end

  def send_final_submission_approved_email(submission)
    WorkflowMailer.final_submission_approved(submission).deliver
  end

  def send_final_submission_rejected_email(submission)
    WorkflowMailer.final_submission_rejected(submission).deliver
  end

  def send_final_submission_received_email(submission)
    WorkflowMailer.final_submission_received(submission).deliver
  end

  def send_format_review_received_email(submission)
    WorkflowMailer.format_review_received(submission).deliver
  end
end
