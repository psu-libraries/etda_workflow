class WorkflowMailerPreview < ActionMailer::Preview
  def initialize
    @submission = Submission.first
  end

  if current_partner.graduate?
    def format_review_received
      WorkflowMailer.format_review_received(@submission)
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

    def pay_thesis_fee
      WorkflowMailer.pay_thesis_fee(@submission)
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
      WorkflowMailer.final_submission_approved(@submission, 'http://search-url-grad')
    end
  end

  def access_level_updated
    @submission = Submission.first
    WorkflowMailer.access_level_updated('author_full_name': @submission.author_full_name, 'title': @submission.title, 'degree_type': @submission.degree_type.name, 'new_access_level_label': 'Open Access', 'old_access_level_label': 'Restricted', 'graduation_year': @submission.year)
  end

  def gem_audit_email
    audit_results = 'Vulnerable Gem Found\n A fake gem to test\n CVE-bogus1234'
    WorkflowMailer.gem_audit_email(audit_results)
  end
end
