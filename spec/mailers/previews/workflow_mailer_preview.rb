class WorkflowMailerPreview < ActionMailer::Preview
  # NOTE: These email previews require there to be a Submission started in your dev environment.

  SUBMISSION = Submission.last

  def final_submission_rejected
    WorkflowMailer.final_submission_rejected(SUBMISSION)
  end

  def final_submission_approved
    WorkflowMailer.final_submission_approved(SUBMISSION)
  end

  def final_submission_received
    WorkflowMailer.final_submission_received(SUBMISSION)
  end

  unless current_partner.milsch?
    def format_review_rejected
      WorkflowMailer.format_review_rejected(SUBMISSION)
    end

    def format_review_accepted
      WorkflowMailer.format_review_accepted(SUBMISSION)
    end
  end

  def format_review_received
    WorkflowMailer.format_review_received(SUBMISSION)
  end

  def sent_to_committee
    WorkflowMailer.sent_to_committee(SUBMISSION)
  end

  def committee_member_review_request
    WorkflowMailer.committee_member_review_request(SUBMISSION, SUBMISSION.committee_members[0])
  end

  def special_committee_review_request
    WorkflowMailer.special_committee_review_request(SUBMISSION, SUBMISSION.committee_members[0])
  end

  def committee_member_review_reminder
    WorkflowMailer.committee_member_review_reminder(SUBMISSION, SUBMISSION.committee_members[0])
  end

  def committee_rejected_admin
    WorkflowMailer.committee_rejected_admin(SUBMISSION)
  end

  def committee_rejected_author
    WorkflowMailer.committee_rejected_author(SUBMISSION)
  end

  def committee_rejected_committee
    WorkflowMailer.committee_rejected_committee(SUBMISSION)
  end

  def pending_returned_author
    WorkflowMailer.pending_returned_author(SUBMISSION)
  end

  def pending_returned_committee
    WorkflowMailer.pending_returned_committee(SUBMISSION)
  end

  def committee_approved
    WorkflowMailer.committee_approved(SUBMISSION)
  end

  def release_for_publication
    WorkflowMailer.release_for_publication(SUBMISSION)
  end

  def release_for_publication_metadata_only
    WorkflowMailer.release_for_publication_metadata_only(SUBMISSION)
  end

  def access_level_updated
    email = {
      author_alternate_email_address: "author alt address",
      cc_email_addresses: ["cc's"],
      new_access_level_label: "Restricted",
      old_access_level_label: "Open",
      degree_type: "Thesis",
      graduation_year: "2009"
    }
    WorkflowMailer.access_level_updated(email)
  end

  if current_partner.graduate?

    def nonvoting_approval_reminder
      WorkflowMailer.nonvoting_approval_reminder(SUBMISSION, SUBMISSION.committee_members[0])
    end

    def seventh_day_to_chairs
      WorkflowMailer.seventh_day_to_chairs(SUBMISSION)
    end

    def seventh_day_to_author
      WorkflowMailer.seventh_day_to_author(SUBMISSION)
    end

    def advisor_rejected
      WorkflowMailer.advisor_rejected(SUBMISSION)
    end

    def advisor_funding_discrepancy
      WorkflowMailer.advisor_funding_discrepancy(SUBMISSION)
    end
  end

  if current_partner.graduate? || current_partner.honors?
    def author_release_warning
      WorkflowMailer.author_release_warning(SUBMISSION)
    end
  end
end
