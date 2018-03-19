class LegacyLoadHelper
  attr_accessor :data

  def initialize
    @data ||= data_loader.first
  end

  def data_loader
    @legacy_data = [
      author_data: load_file('authors.yml'),
      program_data: load_file('programs.yml'),
      degree_type_data: load_file('degree_types.yml'),
      committee_role_data: load_file('committee_roles.yml'),
      degree_data: load_file('degrees.yml'),
      submission_data: load_file('submissions.yml'),
      format_review_file_data: load_file('format_review_files.yml'),
      final_submission_file_data: load_file('final_submission_files.yml'),
      keyword_data: load_file('keywords.yml'),
      committee_member_data: load_file('committee_members.yml'),
      invention_data: load_file('invention_disclosures.yml')
    ]
  end

  def author
    @data[:author_data]
  end

  def degree_type
    @data[:degree_type_data][current_partner.id]
  end

  def degree
    @data[:degree_data][current_partner.id]
  end

  def committee_role
    @data[:committee_role_data][current_partner.id]
  end

  def program
    @data[:program_data]
  end

  def format_review_file
    @data[:format_review_file_data]
  end

  def final_submission_file
    @data[:final_submission_file_data]
  end

  def submission
    @data[:submission_data]
  end

  def keyword
    @data[:keyword_data]
  end

  def committee_member
    @data[:committee_member_data]
  end

  def invention_disclosure
    @data[:invention_data]
  end

  def load_file(filename)
    file = "spec/fixtures/legacy/#{filename}"
    YAML.load_file(file)
  end
end
