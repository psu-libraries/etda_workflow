class OutboundLionPathRecord < ApplicationRecord
  serialize :status_data
  validates :status_data, :transaction_id, :submission_id, presence: true

  attr_accessor :submission
  attr_accessor :original_title
  attr_accessor :original_alternate_email
  attr_accessor :thesis_detail
  # attr_accessor :thesis_params
  # #AuthorSerializer.new(s).attributes.merge(academic_plan: SubmissionSerializer.author_submission(s))

  def self.active?
    @lion_path_outbound_active ||= Rails.application.config_for(:lion_path)[current_partner.id.to_s][:lion_path_outbound]
  end

  def report_status_change
    return unless OutboundLionPathRecord.active?

    OutboundLionPathRecord.new(base_attributes.merge(status_data: status_record_data)).to_lionpath
  end

  def report_title_change
    return unless OutboundLionPathRecord.active?
    return if no_change_occurred(submission.title, original_title)

    OutboundLionPathRecord.new(base_attributes.merge(status_data: attribute_change_data)).to_lionpath
  end

  def report_email_change
    return if !OutboundLionPathRecord.active? || submission.nil?
    return if no_change_occurred(submission.author.alternate_email_address, original_alternate_email)

    OutboundLionPathRecord.new(base_attributes.merge(status_data: attribute_change_data)).to_lionpath
  end

  def report_deleted_submission
    return unless OutboundLionPathRecord.active?

    OutboundLionPathRecord.new(base_attributes.merge(status_data: status_record_delete_data)).to_lionpath
  end

  def to_lionpath
    save!
    # puts status_data.inspect
    # x= { PE_ETD_THESIS_REQ1: { PE_ETD_THESIS: status_data }}.as_json
    # puts x.inspect
    # EtdaLionPathStatusUpdateJob(LionPath::LionPathConnection.send_thesis_update(thesis_params, { PE_ETD_THESIS_REQ1: { PE_ETD_THESIS: status_data }} ))
    # EtdaLionpathStatusUpdateJob.perform_later(status_data.to_json)
    # EtdaLionpathStatusUpdateJob.perform_later(status_data.to_xml(root: 'etd-status'))
  end

  private

  def thesis_params
    { EmplID: submission.author.psu_idn, alternate_email: submission.author.alternate_email.to_s, academic_career: "GRAD" }
  end

  def no_change_occurred(attr1, attr2)
    return true if attr1.nil? || attr2.nil?

    attr1.strip == attr2.strip
  end

  def base_attributes
    { submission_id: submission.id, transaction_id: submission.id }
  end

  def status_record_delete_data
    [{ degree_code: degree, thesis_title: submission.cleaned_title, thesis_status: "#{submission.status}-Deleted", thesis_status_date: Time.zone.now.strftime("%Y-%m-%d %H:%M:%S"), access_level: LionPath::Crosswalk.etd_to_lp_access(submission.access_level), embargo_start_date: '', embargo_end_date: '' }]
  end

  def status_record_data
    [{ degree_code: degree, thesis_title: submission.cleaned_title, thesis_status: submission.status, thesis_status_date: status_date, access_level: LionPath::Crosswalk.etd_to_lp_access(submission.access_level), embargo_start_date: embargo_start, embargo_end_date: embargo_end }]
  end

  def attribute_change_data
    [{ degree_code: degree, thesis_title: submission.cleaned_title, thesis_status: submission.status, thesis_status_date: submission.updated_at, access_level: LionPath::Crosswalk.etd_to_lp_access(submission.access_level), embargo_start_date: embargo_start, embargo_end_date: embargo_end }]
  end

  def degree
    return 'unknown' unless submission.using_lionpath?

    submission.author.inbound_lion_path_record.lion_path_degree_code || 'unknown'
  end

  def status_date
    format_date(SubmissionStates::StateGenerator.state_for_name(submission.status).status_date(submission))
  end

  def embargo_start
    return 'N/A' if submission.open_access?

    format_date(submission.released_metadata_at)
  end

  def embargo_end
    return 'N/A' if submission.open_access?

    format_date(submission.released_for_publication_at)
  end

  def degree_code
    return 'unknown' if submission.degree_type.nil?
    return '_PHD' if submission.degree_type.id == DegreeType.default.id

    '_MS'
  end

  def format_date(this_date)
    return 'N/A' if this_date.nil?

    this_date.strftime('%m-%d-%Y')
  end

  def send_to_lionpath?
    return true if current_partner.graduate? && config.lionpath_outbound

    false
  end
end
