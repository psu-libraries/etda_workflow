class InboundLionPathRecord < ApplicationRecord
  belongs_to :author

  serialize :current_data

  validates :lion_path_degree_code, presence: :lp_valid_degrees

  def self.active?
    @lion_path_inbound_active ||= Rails.application.config_for(:lion_path)[current_partner.id.to_s][:lion_path_inbound]
  end

  def self.etd_role(cm_role)
    committee_role = CommitteeRole.find_by(name: cm_role.strip)
    committee_role = CommitteeRole.add_lp_role(cm_role.strip) if committee_role.nil?
    committee_role.id
  end

  def self.lp_valid_degrees
    @lp_valid_degrees ||= Degree.valid_degrees_list
  end

  def self.transition_to_lionpath(submissions)
    submissions.each do |submission|
      next unless submission.lion_path_degree_code.nil? && submission.using_lionpath? && !submission.beyond_waiting_for_final_submission_response?
      inbound_record = submission.author.inbound_lion_path_record
      lp_degree_code = inbound_record.initialize_lion_path_degree_code(submission)
      submission.update_attribute :lion_path_degree_code, lp_degree_code unless lp_degree_code.nil?
      inbound_record.refresh_academic_plan(submission)
      submission.academic_plan.committee_members_refresh if submission.beyond_collecting_committee?
    end
  end

  def self.records_match?(psu_idn, login_id, lp_record_data)
    return false if lp_record_data.nil?
    author_psu_idn = psu_idn.downcase.strip
    author_login = login_id.downcase.strip
    lp_psu_idn = lp_record_data[LionPath::LpKeys::EMPLOYEE_ID].downcase.strip
    lp_login = lp_record_data[LionPath::LpKeys::ACCESS_ID].downcase.strip
    unless Rails.env.development?
      return false if author_psu_idn != lp_psu_idn || author_login != lp_login
    end
    true
  end

  def retrieve_lion_path_record(psu_idn, access_id)
    # with connection - establish connection.... return 'current_data' and use either mock or production versions
    lp_record = LionPathConnection.new.retrieve_student_information(psu_idn, access_id)
    Rails.logger.info lp_record
    if lp_record[LionPath::LpKeys::ERROR_RESPONSE] # and !author.is_admin? && Rails.env.production?
      LionPath::LionPathError.new(lp_record, access_id).log_error
      return nil
    end
    lp_record_data = lp_record[LionPath::LpKeys::RESPONSE] || nil
    lp_record_data
  end

  def academic_plan
    @academic_plan = LionPath::AcademicPlan.new(self) || []
  end

  def refresh_academic_plan(submission)
    submission.author.populate_lion_path_record(submission.author.psu_idn, submission.author.access_id)
    return true unless submission.using_lionpath?
    refreshed_plan = LionPath::LpEtdPlan.new(submission.academic_plan.selected)
    submission.update_attributes(degree_id: refreshed_plan.etd_degree_id, program_id: refreshed_plan.etd_program_id, year: refreshed_plan.etd_year, semester: refreshed_plan.etd_semester, defended_at: refreshed_plan.etd_defense_date_time)
    return true
  rescue ActiveRecord::RecordInvalid
    return false
  end

  def initialize_lion_path_degree_code(submission)
    return '' if submission.author.inbound_lion_path_record.nil?
    return '' unless InboundLionPathRecord.active? && submission.beyond_collecting_program_information?
    degree_code_slug = Degree.etd_degree_slug(submission.degree_id)
    submission.author.inbound_lion_path_record.current_data[LionPath::LpKeys::PLAN].each do |ap|
      return ap[LionPath::LpKeys::DEGREE_CODE] if ap[LionPath::LpKeys::DEGREE_CODE].last(degree_code_slug.length) == degree_code_slug
    end
    ''
  end
end
