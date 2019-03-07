class WorkflowMailer < ActionMailer::Base
  def format_review_received(submission)
    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Your format review has been received"
  end

  def final_submission_received(submission)
    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Your final #{@submission.degree_type} has been received"
  end

  def final_submission_approved(submission, mailer_base_url)
    @submission = submission
    @author = submission.author
    @mailer_base_url = mailer_base_url
    @dissertation_publish_info = @submission.degree_type.slug == 'dissertation' ? t("#{current_partner.id}.partner.email.final_submission_approved.dissertation_publish_msg") : ''

    mail to: @author.psu_email_address,
         cc: @submission.committee_email_list,
         from: current_partner.email_address,
         subject: "Your #{@submission.degree_type} has been approved"
  end

  def release_for_publication(submission)
    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Your #{@submission.degree_type} is ready for release"
  end

  def pay_thesis_fee(submission)
    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Pay Thesis Processing Fee"
  end

  def access_level_updated(email)
    @email = email
    mail to: @email[:author_alternate_email_address].presence || @email[:author_psu_email_address],
         cc: @email[:cc_email_addresses],
         from: current_partner.email_address,
         subject: "Access Level for your submission has been updated"
  end

  def gem_audit_email(audit_results)
    @audit_results = audit_results
    mail to: 'jxb13@psu.edu',
         from: 'jxb13@psu.edu',
         subject: 'BUNDLE AUDIT: Vulnerable Gems Found'
  end

  def committee_member_reminder(submission_id, recipient_email_address)
    @submission = Submission.find_by(id: submission_id)
    mail to: recipient_email_address,
         from: current_partner.email_address,
         subject: 'Committee Member Reminder'
  end
end
