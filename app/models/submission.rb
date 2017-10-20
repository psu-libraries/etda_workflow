class Submission < ApplicationRecord
  extend Enumerize
  belongs_to :author
  belongs_to :program
  belongs_to :degree

  has_many :committee_members, dependent: :destroy
  has_many :format_review_files, dependent: :destroy
  has_many :final_submission_files, dependent: :destroy
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

  enum_for :access_level, in: ::AccessLevel.valid_levels, default: '', i18n_scope: "#{EtdaUtilities::Partner.current.id}.access_level"

  def access_level=(access_level)
    @decorated_level = access_level
    @decorated_level = AccessLevel.new(@decorated_level) unless @decorated_level.class == AccessLevel
    super(@decorated_level)
  end

  def access_level
    @decorated_level = super()
    @decorated_level ||= ''
    @decorated_level = AccessLevel.new(@decorated_level) unless @decorated_level.class == AccessLevel
  end

  def access_level_key
    access_level.to_s
  end

  after_initialize :set_status_to_collecting_program_information

  validates :author_id,
            :title,
            :program_id,
            presence: true

  validates :semester,
            :year,
            presence: true # ,
  # unless: proc { InboundLionPathRecord.active? }

  validates :abstract,
            :keywords,
            :access_level,
            presence: true # ,
  # if: proc { |s| s.beyond_waiting_for_format_review_response? }

  validates :defended_at,
            presence: true # ,
  # if: proc { |s| s.beyond_waiting_for_format_review_response? && EtdaUtilities::Partner.current.graduate? }   # && !InboundLionPathRecord.active? }

  validate :agreement_to_terms # ,
  # if: proc { |s| s.beyond_waiting_for_format_review_response? }

  validates :title,
            length: { maximum: 400 }

  validates :public_id,
            uniqueness: true,
            allow_nil: true

  validate :check_title_capitalization

  validates :semester, inclusion: { in: Semester::SEMESTERS }
  validates :degree_id, presence: true
  validates :access_level, inclusion: { in: ::AccessLevel.valid_levels }

  # validates :invention_disclosure, invention_disclosure_number: true, if: proc { |s| s.restricted? && s.invention_disclosure_expected? }

  validates :year, numericality: { only_integer: true }

  validates :status, inclusion: { in: SubmissionStatus::WORKFLOW_STATUS }

  accepts_nested_attributes_for :committee_members,
                                reject_if:
                                    ->(attributes) { attributes.except(:submission_id).values.all?(&:blank?) },
                                allow_destroy: true
  accepts_nested_attributes_for :format_review_files, allow_destroy: true
  accepts_nested_attributes_for :final_submission_files, allow_destroy: true
  accepts_nested_attributes_for :keywords, allow_destroy: true
  # accepts_nested_attributes_for :invention_disclosures,
  #                             allow_destroy: true,
  #                             limit: 1,
  #                             reject_if: :reject_disclosure_number

  scope :format_review_is_incomplete, lambda {
    where(status: ['collecting program information', 'collecting committee', 'collecting format review files', 'collecting format review files rejected'])
  }
  scope :format_review_is_submitted, -> { where(status: 'waiting for format review response') }
  scope :format_review_is_completed, -> { where('status = ? OR status = ?', "collecting final submission files", "format review is accepted").where(final_submission_rejected_at: nil) }

  scope :final_submission_is_incomplete, -> { where('status LIKE "collecting final submission files%"').where.not(final_submission_rejected_at: nil) }
  scope :final_submission_is_submitted, -> { where(status: 'waiting for final submission response') }
  scope :final_submission_is_approved, -> { where(status: 'waiting for publication release') }
  scope :released_for_publication, -> { where('status LIKE "released for publication%"') }
  scope :final_is_restricted_institution, -> { where(status: 'released for publication', access_level: 'restricted_to_institution') }
  scope :final_is_withheld, -> { where('status LIKE "released for publication%"').where(access_level: 'restricted') }
  scope :ok_to_release, -> { where('released_for_publication_at <= ?', Time.zone.today.end_of_day) }

  # Initialize our committee members with empty records for each of the required roles.

  def set_status_to_collecting_program_information
    self.status = 'collecting program information' if self.new_record? && status.nil?
  end

  def title_words
    title.try(:split, ' ') || []
  end

  def check_title_capitalization
    return if allow_all_caps_in_title

    word_in_all_caps = false
    title_words.each do |w|
      word_in_all_caps = true if w.length > 1 && w.upcase == w
    end
    errors[:title] << I18n.t('activerecord.errors.models.submission.attributes.title.capitalization') if word_in_all_caps
  end

  def agreement_to_terms
    errors.add(:base, 'You must agree to terms') unless has_agreed_to_terms?
  end
end
