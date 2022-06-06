class WorkflowMailerPreview < ActionMailer::Preview
  if current_partner.graduate?
    def format_review_received
      WorkflowMailer.format_review_received(Submission.last)
    end

    def final_submission_received
      WorkflowMailer.final_submission_received(@submission)
    end

    def final_submission_approved_dissertation
      @submission.degree = Degree.where(degree_type_id: DegreeType.default).first
      @submission.save
      WorkflowMailer.final_submission_approved(@submission, 'http://search-url-grad')
    end

    def final_submission_approved_masters
      @submission.degree = Degree.where(degree_type_id: DegreeType.last).first
      WorkflowMailer.final_submission_approved(@submission, 'http://search-url-grad')
    end
  end

  if current_partner.honors?

    def final_submission_approved
      WorkflowMailer.final_submission_approved(@submission, 'http://search-url-honors')
    end
  end

  if current_partner.milsch?
    def format_review_received
      WorkflowMailer.format_review_received(@submission)
    end

    def final_submission_received
      WorkflowMailer.final_submission_received(@submission)
    end

    def final_submission_approved
      @submission.degree = Degree.where(degree_type_id: DegreeType.default).first
      WorkflowMailer.final_submission_approved(@submission, 'http://search-url-milsch')
    end
  end

  def access_level_updated
    @submission = Submission.first
    WorkflowMailer.access_level_updated('author_full_name': @submission.author_full_name, 'title': @submission.title, 'degree_type': @submission.degree_type.name, 'new_access_level_label': 'Open Access', 'old_access_level_label': 'Restricted', 'graduation_year': @submission.preferred_year)
  end

  def vulnerability_audit_email
    audit_results = 'Vulnerable Gem Found\n A fake gem to test\n CVE-bogus1234'
    WorkflowMailer.vulnerability_audit_email(audit_results)
  end

  def open_access_report
    @submissions = [Submission.first, Submission.second, Submission.third]
    csv = CSV.generate { |c| c << ['HEADERS'] }
    WorkflowMailer.open_access_report('1/1/01 - 1/1/02', csv)
  end

  def committee_rejected_author
    submission = Submission.where(status: 'waiting for final submission response').sample
    WorkflowMailer.committee_rejected_author(submission)
  end

  def seventh_day_to_chairs
    submission = Submission.where(status: 'waiting for committee review').sample
    WorkflowMailer.seventh_day_to_chairs(submission)
  end

  def seventh_day_to_author
    submission = Submission.where(status: 'waiting for committee review').sample
    WorkflowMailer.seventh_day_to_author(submission)
  end

  def committee_member_review_request_to_core_members
    submission = Submission.where(status: 'waiting for committee review').sample
    committee_member = submission.committee_members.select(&:core_committee_member?).first
    WorkflowMailer.send_committee_review_requests(submission, committee_member)
  end

  def committee_member_review_request_to_other_members
    submission = Submission.where(status: 'waiting for committee review').sample
    committee_member = submission.committee_members.reject(&:core_committee_member?).first
    WorkflowMailer.send_committee_review_requests(submission, committee_member)
  end

  def special_committee_review_request_initial
    submission = Submission.where(status: 'waiting for committee review').first
    committee_member = submission.committee_members.first
    committee_member.approval_started_at = nil
    submission.save

    WorkflowMailer.special_committee_review_request(submission, committee_member)
  end

  def special_committee_review_request_reminder
    submission = Submission.where(status: 'waiting for committee review').first
    committee_member = submission.committee_members.first
    WorkflowMailer.special_committee_review_request(submission, committee_member)
  end
end
