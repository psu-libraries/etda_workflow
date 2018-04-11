class LegacyDatabaseHelper
  attr_accessor :tables
  attr_accessor :table_field_list

  def author_columns
    Author.column_names - ['confidential_hold', 'confidential', 'is_admin', 'is_site_admin', 'opt_out_email', 'opt_out_default']
  end

  def submission_columns
    Submission.column_names
  end

  def degree_type_columns
    DegreeType.column_names
  end

  def degree_columns
    Degree.column_names
  end

  def program_columns
    Program.column_names
  end

  def keyword_columns
    Keyword.column_names
  end

  def committee_member_columns
    CommitteeMember.column_names
  end

  def format_review_file_columns
    FormatReviewFile.column_names
  end

  def final_submission_file_columns
    FinalSubmissionFile.column_names
  end

  def committee_role_columns
    CommitteeRole.column_names
  end

  def invention_disclosure_columns
    InventionDisclosure.column_names
  end
end
