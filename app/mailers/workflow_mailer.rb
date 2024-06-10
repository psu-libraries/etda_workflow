class WorkflowMailer < ActionMailer::Base
  class InvalidPartner < StandardError; end
  extend MailerActions

  def format_review_received(submission)
    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Your format review has been received"
  end

  def format_review_accepted(submission)
    raise InvalidPartner unless current_partner.sset? || current_partner.honors?

    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Your format review has been accepted"
  end

  def format_review_rejected(submission)
    raise InvalidPartner unless current_partner.sset? || current_partner.honors?

    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Your format review has been rejected"
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
    @url = EtdUrls.new.explore.to_s

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
    @explore_url = "#{EtdUrls.new.explore}/catalog/#{submission.public_id}"

    mail to: [@author.psu_email_address, @author.alternate_email_address],
         from: current_partner.email_address,
         subject: "Your #{@submission.degree_type} has been released"
  end

  def release_for_publication_metadata_only(submission)
    @submission = submission
    @author = submission.author
    @explore_url = "#{EtdUrls.new.explore}/catalog/#{submission.public_id}"

    mail to: [@author.psu_email_address, @author.alternate_email_address],
         from: current_partner.email_address,
         subject: "Your #{@submission.degree_type}'s metadata has been released"
  end

  def access_level_updated(email)
    @email = email
    mail to: @email[:author_alternate_email_address].presence || @email[:author_psu_email_address],
         cc: @email[:cc_email_addresses],
         from: current_partner.email_address,
         subject: "Access Level for your submission has been updated"
  end

  def semester_release_report(date_range, csv, filename)
    @date_range = date_range
    attachments[filename.to_s] = csv
    mail to: I18n.t('external_contacts.ul_cataloging.email_address').to_s,
         cc: I18n.t('devs.lead.primary_email_address'),
         from: current_partner.email_address,
         subject: "eTDs Released Between #{@date_range}"
  end

  def vulnerability_audit_email(audit_results)
    @audit_results = audit_results
    mail to: I18n.t('devs.lead.primary_email_address').to_s,
         from: I18n.t('devs.lead.primary_email_address').to_s,
         subject: 'BUNDLE & YARN AUDIT: Vulnerabilities Found'
  end

  def verify_files_email(verify_files_results)
    @verify_files_results = verify_files_results
    mail to: I18n.t('devs.lead.primary_email_address').to_s,
         from: I18n.t('devs.lead.primary_email_address').to_s,
         subject: 'VERIFY FILES: Misplaced files found'
  end

  def sent_to_committee(submission)
    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Committee Review Initiated"
  end

  def committee_member_review_request(submission, committee_member)
    @submission = submission
    @committee_member = committee_member
    @author = submission.author
    @review_url = "#{EtdUrls.new.workflow}/approver"

    @committee_member.update approval_started_at: DateTime.now if @committee_member.approval_started_at.blank?
    @committee_member.update_last_reminder_at DateTime.now

    @core_member_note = @committee_member.core_committee_member? ? "You have seven days to complete your review. Failure to review in the seven days may result in your removal from the committee." : ""

    mail to: @committee_member.email,
         from: current_partner.email_address,
         subject: "#{current_partner.name} #{submission.degree_type} Review Request"
  end

  def special_committee_review_request(submission, committee_member)
    @submission = submission
    @committee_member = committee_member
    @token = committee_member.committee_member_token ? committee_member.committee_member_token.authentication_token : 'X'
    @author = submission.author
    @review_url = "#{EtdUrls.new.workflow}/special_committee/#{@token}"

    @seven_day_note = @committee_member.approval_started_at.blank? ? "You have seven days to complete your review. Failure to review in the seven days may result in your removal from the committee." : ""

    @committee_member.update approval_started_at: DateTime.now if @committee_member.approval_started_at.blank?
    @committee_member.update_last_reminder_at DateTime.now

    mail to: @committee_member.email,
         from: current_partner.email_address,
         subject: "#{current_partner.name} #{submission.degree_type} Review Request"
  end

  def committee_member_review_reminder(submission, committee_member)
    @submission = submission
    @committee_member = committee_member
    @author = submission.author
    @review_url = "#{EtdUrls.new.workflow}/approver"

    @committee_member.update approval_started_at: DateTime.now if @committee_member.approval_started_at.blank?
    @committee_member.update_last_reminder_at DateTime.now

    mail to: @committee_member.email,
         from: current_partner.email_address,
         subject: "#{current_partner.name} #{submission.degree_type} Review Reminder"
  end

  def nonvoting_approval_reminder(submission, committee_member)
    @submission = submission
    @committee_member = committee_member
    @author = submission.author
    @review_url = "#{EtdUrls.new.workflow}/approver"

    mail to: @committee_member.email,
         from: current_partner.email_address,
         subject: "#{current_partner.name} #{submission.degree_type} Final Review Reminder"
  end

  def seventh_day_to_chairs(submission)
    @submission = submission
    @author = submission.author
    committee_list = submission.voting_committee_members.collect do |cm|
      "#{cm.name} (#{cm.email})" if %w[approved rejected].exclude?(cm.status)
    end
    @committee_list_strf = committee_list.compact.join(', ')

    mail to: [CommitteeMember.program_head(submission)&.email, submission.chairs&.pluck(:email)].flatten.uniq.compact,
         from: current_partner.email_address,
         subject: "#{@author.first_name} #{@author.last_name} Committee 7-day Deadline Reached"
  end

  def seventh_day_to_author(submission)
    program_head_name = CommitteeMember.program_head(submission)&.name
    committee_chair_name = submission.chairs.first&.name
    @submission = submission
    @author = submission.author
    @committee_chair = (committee_chair_name ? " chair (#{committee_chair_name}) and" : nil)
    @program_head = (program_head_name ? "(#{program_head_name}) " : nil)

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "ETD Committee Still Processing"
  end

  def advisor_rejected(submission)
    @submission = submission
    @author = submission.author
    @advisor = submission.advisor

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Advisor Rejected Submission"
  end

  def advisor_funding_discrepancy(submission)
    @submission = submission
    @author = submission.author
    @advisor = submission.advisor

    mail to: @author.psu_email_address,
         cc: @advisor.email,
         from: current_partner.email_address,
         subject: "Advisor Funding Discrepancy"
  end

  def pending_returned_author(submission)
    @submission = submission
    @author = submission.author

    mail to: @author.psu_email_address,
         from: current_partner.email_address,
         subject: "Final Submission Returned for Resubmission"
  end

  def pending_returned_committee(submission)
    @submission = submission
    @author = submission.author
    to = if submission.status_behavior.waiting_for_advisor_review?
           submission.advisor.email
         else
           submission.committee_email_list
         end

    mail to:,
         from: current_partner.email_address,
         subject: "Final Submission Returned to Student for Resubmission"
  end

  def committee_rejected_author(submission)
    @submission = submission
    @author = submission.author
    @review_results = ReviewResultsEmail.new(submission).generate
    to = if current_partner.graduate?
           [@author.psu_email_address, submission.advisor&.email, submission.chairs&.pluck(:email)].flatten.uniq.compact
         else
           @author.psu_email_address
         end

    mail to:,
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

  def committee_rejected_committee(submission)
    @submission = submission
    @author = submission.author
    @title = submission.title
    @email_list = @submission.committee_email_list

    to = if current_partner.graduate?
           @email_list -= [@submission.advisor&.email, @submission.chairs&.pluck(:email)].flatten.uniq
         else
           @email_list
         end

    return if to.blank?

    mail to:,
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
end
