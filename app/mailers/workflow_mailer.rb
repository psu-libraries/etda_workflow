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

  def final_submission_approved(submission)
    @submission = submission
    @author = submission.author
    @url = "#{EtdUrls.new.workflow}/author"

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Your #{@submission.degree_type} has been approved by the #{current_partner.name}"
  end

  def final_submission_rejected(submission)
    @submission = submission
    @author = submission.author
    @url = "#{EtdUrls.new.workflow}/author"

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Your #{@submission.degree_type} has been rejected by the #{current_partner.name}"
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
    mail to: 'ajk5603@psu.edu',
         from: 'ajk5603@psu.edu',
         subject: 'BUNDLE AUDIT: Vulnerable Gems Found'
  end

  def verify_files_email(verify_files_results)
    @verify_files_results = verify_files_results
    mail to: 'ajk5603@psu.edu',
         from: 'ajk5603@psu.edu',
         subject: 'VERIFY FILES: Misplaced files found'
  end

  def committee_member_review_request(submission, committee_member)
    @submission = submission
    @committee_member = committee_member
    @author = submission.author
    @review_url = "#{EtdUrls.new.workflow}/approver"

    @committee_member.update_last_reminder_at DateTime.now

    mail to: @committee_member.email,
         from: current_partner.email_address,
         subject: partner_review_request_subject
  end

  def special_committee_review_request(submission, committee_member)
    @submission = submission
    @committee_member = committee_member
    @token = committee_member.committee_member_token ? committee_member.committee_member_token.authentication_token : 'X'
    @author = submission.author
    @review_url = "#{EtdUrls.new.workflow}/special_committee/#{@token}"

    @committee_member.update_last_reminder_at DateTime.now

    mail to: @committee_member.email,
         from: current_partner.email_address,
         subject: partner_review_request_subject
  end

  def committee_member_review_reminder(submission, committee_member)
    @submission = submission
    @committee_member = committee_member
    @author = submission.author
    @review_url = "#{EtdUrls.new.workflow}/approver"

    @committee_member.update_last_reminder_at DateTime.now

    mail to: @committee_member.email,
         from: current_partner.email_address,
         subject: partner_review_request_subject
  end

  def committee_rejected_author(submission)
    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Committee Rejected Final Submission"
  end

  def committee_rejected_admin(submission)
    @submission = submission
    @author = submission.author

    mail to: current_partner.email_list,
         from: current_partner.email_address,
         subject: "Committee Rejected Final Submission"
  end

  def committee_approved(submission)
    @submission = submission
    @author = submission.author
    @explore_url = EtdUrls.new.explore.to_s

    mail to: @author.psu_email_address,
         cc: [@submission.committee_email_list.uniq, current_partner.email_address].flatten,
         from: current_partner.email_address,
         subject: "Your #{@submission.degree_type} has been approved by committee"
  end

  private

  def partner_review_request_subject
    if current_partner.graduate?
      "#{@submission.degree_type} Needs Approval"
    elsif current_partner.honors?
      "Honors Thesis Needs Approval"
    elsif current_partner.milsch?
      "Millennium Scholars Thesis Review"
    end
  end
end
