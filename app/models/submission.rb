# frozen_string_literal: true

class Submission < ApplicationRecord
  extend Enumerize

  include AdminStatuses

  belongs_to :author
  belongs_to :program
  belongs_to :degree

  has_many :committee_members, dependent: :destroy
  has_many :format_review_files, inverse_of: :submission, dependent: :destroy
  has_many :final_submission_files, inverse_of: :submission, dependent: :destroy
  has_many :keywords, dependent: :destroy, validate: true
  has_many :invention_disclosures, dependent: :destroy, validate: true

  delegate :name, to: :program, prefix: :program
  delegate :name, to: :degree, prefix: :degree
  delegate :degree_type, to: :degree
  delegate :required_committee_roles, to: :degree_type
  delegate :first_name, to: :author, prefix: :author
  delegate :last_name, to: :author, prefix: :author
  delegate :full_name, to: :author, prefix: true
  delegate :psu_email_address, to: :author, prefix: true
  delegate :access_id, to: :author, prefix: false
  delegate :alternate_email_address, to: :author, prefix: false
  delegate :confidential?, to: :author

  enumerize :access_level, in: AccessLevel.valid_levels, default: '' # , i18n_scope: "#{current_partner.id}.access_level"

  def access_level_key
    access_level.to_s
  end

  def status_behavior
    SubmissionStatus.new(self)
  end

  def approval_status_behavior
    ApprovalStatus.new(self)
  end

  def program_head
    CommitteeMember.program_head(self)
  end

  def collect_program_chairs
    program.program_chairs.where('program_chairs.campus = ?', campus)
  end

  after_initialize :set_status_to_collecting_program_information
  after_initialize :initialize_access_level

  attr_accessor :author_edit

  # a submission belongs to degree, program, and author so these must be present regardless of who is editing
  validates :author_id,
            :degree_id,
            :program_id, presence: true

  validates :semester,
            presence: true,
            inclusion: { in: Semester::SEMESTERS },
            if: proc { |s| s.author_edit }

  validates :lionpath_semester,
            allow_blank: true,
            inclusion: { in: Semester::SEMESTERS }

  validates :year,
            numericality: { only_integer: true },
            presence: true,
            if: proc { |s| s.author_edit }

  validates :lionpath_year,
            allow_blank: true,
            numericality: { only_integer: true }

  validates :title,
            length: { maximum: 400 },
            presence: true, if: proc { |s| s.author_edit }

  validates :federal_funding, inclusion: { in: [true, false] }, if: proc { |s| s.status_behavior.beyond_collecting_committee? && s.author_edit }

  validates :abstract,
            :keywords,
            :access_level,
            :has_agreed_to_terms,
            presence: true, if: proc { |s| s.status_behavior.beyond_waiting_for_format_review_response? && s.author_edit }

  validates :defended_at,
            presence: true, if: proc { |s| s.status_behavior.beyond_waiting_for_format_review_response? && current_partner.graduate? && s.author_edit }

  validates :proquest_agreement,
            presence: true, if: proc { |s| s.status_behavior.beyond_waiting_for_format_review_response? && current_partner.graduate? && degree_type.slug == 'dissertation' && s.author_edit }

  validates :public_id,
            uniqueness: { case_sensitive: true },
            allow_nil: true

  validate :check_title_capitalization

  validates :access_level, inclusion: { in: AccessLevel::ACCESS_LEVEL_KEYS }, if: proc { |s| s.status_behavior.beyond_collecting_final_submission_files? && s.author_edit }

  validates :invention_disclosure, invention_disclosure_number: true, if: proc { |s| s.status_behavior.beyond_collecting_format_review_files? && !s.status_behavior.released_for_publication? }

  validates :has_agreed_to_publication_release, presence: true, if: proc { |s| s.status_behavior.beyond_waiting_for_format_review_response? && s.author_edit && author.confidential? }

  validate :format_review_file_check

  attr_reader :previous_access_level
  after_update :cache_access_level

  def cache_access_level
    @previous_access_level = access_level_before_last_save || ''
  end

  validates :status, inclusion: { in: SubmissionStatus::WORKFLOW_STATUS }

  accepts_nested_attributes_for :committee_members,
                                reject_if:
                                    ->(attributes) { attributes.except(:submission_id).values.all?(&:blank?) },
                                allow_destroy: true
  accepts_nested_attributes_for :format_review_files, allow_destroy: true
  accepts_nested_attributes_for :final_submission_files, allow_destroy: true
  accepts_nested_attributes_for :keywords, allow_destroy: true
  accepts_nested_attributes_for :invention_disclosures,
                                allow_destroy: true,
                                limit: 1

  scope :format_review_is_incomplete, lambda {
    where(status: ['collecting program information', 'collecting committee', 'collecting format review files', 'collecting format review files rejected'])
  }
  scope :format_review_is_submitted, -> { where(status: 'waiting for format review response') }
  scope :format_review_is_completed, -> { where('status = ? OR status = ?', "collecting final submission files", "format review is accepted").where(final_submission_rejected_at: nil) }

  scope :final_submission_is_pending, -> { where(status: ['waiting for advisor review', 'waiting for committee review', 'waiting for head of program review']) }
  scope :committee_review_is_rejected, -> { where(status: 'waiting for committee review rejected') }
  scope :final_submission_is_incomplete, -> { where(status: "collecting final submission files rejected").where.not(final_submission_rejected_at: nil) }
  scope :final_submission_is_submitted, -> { where(status: 'waiting for final submission response') }
  scope :final_submission_is_approved, -> { where(status: 'waiting for publication release') }
  scope :final_submission_is_on_hold, -> { where(status: 'waiting in final submission on hold') }
  scope :released_for_publication, -> { where('status LIKE "released for publication%"') }
  scope :final_is_restricted_institution, -> { where('status LIKE "released for publication%"').where(access_level: 'restricted_to_institution') }
  scope :final_is_withheld, -> { where('status LIKE "released for publication%"').where(access_level: 'restricted') }
  scope :ok_to_release, -> { where('released_for_publication_at <= ?', Time.zone.today.end_of_day) }

  def advisor
    CommitteeMember.advisors(self).first
  end

  def chairs
    chairs_array = []
    committee_members.each do |cm|
      chairs_array << cm if cm.committee_role.name.downcase =~ /(?<!\/)chair/
    end
    chairs_array
  end

  def set_status_to_collecting_program_information
    self.status = 'collecting program information' if new_record? && status.nil?
  end

  def reset_committee_reviews
    committee_members.each do |committee_member|
      committee_member.update! status: '', approved_at: nil, rejected_at: nil,
                               reset_at: DateTime.now, approval_started_at: nil
    end
  end

  def reset_program_head_review
    program_head&.update status: ''
  end

  def initialize_access_level
    self.access_level = '' if new_record? && access_level.nil?
  end

  def title_words
    title.try(:split, ' ') || []
  end

  def federal_funding_display
    return if federal_funding.nil?

    federal_funding ? 'Yes' : 'No'
  end

  def check_title_capitalization
    return if allow_all_caps_in_title

    word_in_all_caps = false
    title_words.each do |w|
      word_in_all_caps = true if w.scan(/[A-Z]/).length > 4
    end
    errors[:title] << I18n.t('activerecord.errors.models.submission.attributes.title.capitalization') if word_in_all_caps
  end

  def invention_disclosure
    # return '' unless current_partner.graduate?
    @invention_disclosure = invention_disclosures.present? ? invention_disclosures.first : invention_disclosures.build
    @invention_disclosure
  end

  def reject_disclosure_number(attributes)
    # destroy the invention disclosure id_number if it's no longer needed
    # submission is edited and submitted with blank invention disclosure id_number (as an author or admin) or
    # the access level is not restricted and the public_id is nil (this means submission has never been released for publication)
    exists = attributes['id'].present?
    # empty = attributes['id_number'].blank?
    # attributes['_destroy'] = 'true' if exists && (!restricted? && !published?)
    !(exists || (!restricted? && !published?))
  end

  def preferred_semester_and_year
    "#{semester} #{year}".presence || "#{lionpath_semester} #{lionpath_year}"
  end

  def preferred_year
    year.presence || lionpath_year
  end

  def preferred_semester
    semester.presence || lionpath_semester
  end

  def admin_can_edit?
    true
  end

  def ok_to_release?
    released_for_publication_at.present? && released_for_publication_at <= Time.zone.today.end_of_day
  end

  def published?
    return true if public_id.present?

    false
  end

  def cleaned_title
    return '' if title.blank?

    clean_title = title.split(/\r\n/).join.strip || ''
    clean_title = clean_title.strip_control_and_extended_characters
    clean_title
  end

  def committee_email_list
    list = []
    committee_members.each do |cm|
      list << cm.email
    end
    list.uniq
  end

  def keyword_list
    list = []
    keywords.each do |k|
      list << k.word
    end
    list
  end

  def delimited_keywords
    keywords.map(&:word).join(',')
  end

  def delimited_keywords=(comma_separated_keywords)
    clean_keywords = comma_separated_keywords
                     .split(',')
                     .map(&:strip)
                     .reject(&:blank?)

    new_keywords = clean_keywords.map do |keyword|
      Keyword.new(word: keyword)
    end

    self.keywords = new_keywords
  end

  def status_class
    status.parameterize
  end

  def current_access_level
    AccessLevel.new(access_level)
  end

  def format_review_rejected?
    status_behavior.collecting_format_review_files_rejected?
    # status_behavior.collecting_format_review_files? && format_review_rejected_at.present?
  end

  def final_submission_rejected?
    status_behavior.collecting_final_submission_files_rejected?
    # status_behavior.collecting_final_submission_files? && final_submission_rejected_at.present?
  end

  delegate :open_access?, to: :access_level

  delegate :restricted?, to: :access_level

  delegate :restricted_to_institution?, to: :access_level

  def publication_release_access_level
    return 'open_access' if status_behavior.released_for_publication? # full release of submission that was held for 2 years

    access_level # keep access_level for restricted & PSU-only starting hold or open_access
  end

  def publication_release_date(date_to_release)
    # determine the date use for released_publication_at
    # restricted submissions will be held for 2 years then released.  For 2 yr. restriction do this:
    #   metadata_released_at = date_to_release
    #   released_for_publication_at = date_to_release + 2 years
    # release restricted after 2-year-hold (time period may be longer)
    #   released_fo_publication_at = date_to_release
    return date_to_release if open_access?

    two_years_later = date_to_release.to_date + 2.years
    two_years_later
  end

  def update_format_review_timestamps!(time)
    update_attribute(:format_review_files_uploaded_at, time)
    update_attribute(:format_review_files_first_uploaded_at, time) if format_review_files_first_uploaded_at.blank?
  end

  def update_final_submission_timestamps!(time)
    update_attribute(:final_submission_files_uploaded_at, time)
    update_attribute(:final_submission_files_first_uploaded_at, time) if final_submission_files_first_uploaded_at.blank?
  end

  def self.release_for_publication(submission_ids, date_to_release, release_type)
    # Submission.transaction do
    SubmissionReleaseService.new.publish(submission_ids, date_to_release, release_type)
    # end
  end

  def self.extend_publication_date(submission_ids, date_to_release)
    where(id: submission_ids).find_each { |s| s.update!(released_for_publication_at: date_to_release) }
  end

  def voting_committee_members
    seen_access_ids = []
    voting_no_dups = []
    flagged_voting = committee_members.collect { |cm| cm if cm.is_voting }.compact
    flagged_voting.each do |member|
      voting_no_dups << member unless seen_access_ids.include? member.access_id
      seen_access_ids << member.access_id
    end
    voting_no_dups << program_head unless head_of_program_is_approving?
    voting_no_dups.compact
  end

  # Initialize our committee members with empty records for each of the required roles.
  def build_committee_members_for_partners
    required_committee_roles.each do |role|
      next if role.is_program_head && program_head.present?

      committee_members.build(committee_role: role, is_required: true)
    end
  end

  def head_of_program_is_approving?
    degree.degree_type.approval_configuration.head_of_program_is_approving
  end

  def committee_review_requests_init
    seen_access_ids = []
    committee_members.each do |committee_member|
      next if committee_member.is_program_head ||
              (committee_member == committee_member.submission.advisor && current_partner.graduate?)

      committee_member.update! approval_started_at: DateTime.now
      next if seen_access_ids.include?(committee_member.access_id) ||
              (%w[approved rejected].include? committee_member.status)

      WorkflowMailer.send_committee_review_requests(self, committee_member)

      CommitteeReminderWorker.perform_in(4.days, id, committee_member.id)
      seen_access_ids << committee_member.access_id
    end
  end

  def proquest_agreement=(input)
    super(input)
    return unless proquest_agreement_changed? && ActiveModel::Type::Boolean.new.cast(input)

    self[:proquest_agreement_at] = DateTime.now
  end

  private

    def format_review_file_check
      # no validation for admin users
      return true unless author_edit
      # only require file when author submitting format review
      return true unless status_behavior.collecting_format_review_files?

      if format_review_files.nil? || format_review_files.blank?
        # errors[] << 'You must upload a format review file.'
        false
      else
        true
      end
    end
end
