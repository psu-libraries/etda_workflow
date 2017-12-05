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
  delegate :confidential?, to: :author

  enumerize :access_level, in: ::AccessLevel.valid_levels, default: '', i18n_scope: "#{current_partner.id}.access_level"

  def access_level_key
    access_level.to_s
  end

  def status_behavior
    SubmissionStatus.new(self)
  end

  after_initialize :set_status_to_collecting_program_information
  after_initialize :initialize_access_level

  validates :author_id,
            :title,
            :program_id,
            presence: true

  validates :semester,
            :year,
            presence: true # , unless: proc { InboundLionPathRecord.active? }

  validates :abstract,
            :keywords,
            :access_level,
            presence: true, if: proc { |s| s.status_behavior.beyond_waiting_for_format_review_response? }

  validates :defended_at,
            presence: true, if: proc { |s| s.status_behavior.beyond_waiting_for_format_review_response? && current_partner.graduate? } # && !InboundLionPathRecord.active? }

  validate :agreement_to_terms, if: proc { |s| s.status_behavior.beyond_waiting_for_format_review_response? }

  validates :title,
            length: { maximum: 400 }

  validates :public_id,
            uniqueness: true,
            allow_nil: true

  validate :check_title_capitalization

  validates :semester, inclusion: { in: Semester::SEMESTERS }
  validates :degree_id, presence: true
  validates :access_level, inclusion: { in: AccessLevel::ACCESS_LEVEL_KEYS }

  validates :invention_disclosure, invention_disclosure_number: true, if: proc { |s| s.status == 'collecting final submission files' }

  validates :year, numericality: { only_integer: true }

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
                                limit: 1,
                                reject_if: :reject_disclosure_number

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
  scope :final_is_embargoed, -> { where(status: 'confidential hold embargo') }

  def set_status_to_collecting_program_information
    self.status = 'collecting program information' if self.new_record? && status.nil?
  end

  def initialize_access_level
    self.access_level = '' if self.new_record? && access_level.nil?
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

  def invention_disclosure
    # return '' unless current_partner.graduate?
    @invention_disclosure = invention_disclosures.present? ? invention_disclosures.first : invention_disclosures.build
    @invention_disclosure
  end

  def reject_disclosure_number(attributes)
    # destroy the invention disclosure id_number if it's no longer needed
    # submission is edited and submitted with blank invention disclosure id_number
    exists = attributes['id'].present?
    empty = attributes['id_number'].blank?
    attributes.merge!(_destroy: 1) if exists && empty
    (!exists && empty)
  end
end
