# frozen_string_literal: true

class CommitteeMember < ApplicationRecord
  class ProgramHeadMissing < StandardError; end
  attr_accessor :approver_controller, :federal_funding_confirmation

  validate :validate_email, :one_head_of_program_check, :validate_status,
           :validate_notes, :validate_federal_funding_used
  validates :committee_role_id,
            :name,
            :email, presence: true

  belongs_to :submission
  belongs_to :committee_role
  belongs_to :faculty_member, optional: true
  belongs_to :approver, optional: true
  has_one :committee_member_token, dependent: :destroy

  delegate :is_program_head, to: :committee_role

  STATUS = [
    '',
    'pending',
    'approved',
    'rejected',
    'did not vote'
  ].freeze

  def self.advisors(submission)
    advisors_array = []
    submission.committee_members.each do |cm|
      advisors_array << cm if cm.committee_role.name.downcase =~ /advisor|adviser/
    end
    advisors_array
  end

  def self.advisor_name(submission)
    advisors_array = CommitteeMember.advisors(submission)
    return '' if advisors_array.empty?

    advisors_array.first.name
  end

  def self.thesis_supervisors(submission)
    supervisors_array = []
    submission.committee_members.each do |cm|
      supervisors_array << cm if cm.committee_role.name.downcase == 'thesis supervisor'
    end
    supervisors_array
  end

  def self.thesis_supervisor_name(submission)
    supervisors_array = CommitteeMember.thesis_supervisors(submission)
    return '' if supervisors_array.empty?

    supervisors_array.first.name
  end

  def self.remove_committee_members(submission)
    submission.committee_members.each(&:destroy)
    submission.save
  end

  def self.current_committee(submission_id)
    CommitteeMember.where(submission_id:).pluck(:committee_role_id, :is_required, :name, :email)
  end

  def self.program_head(submission)
    submission.committee_members.joins(:committee_role).find_by('committee_roles.is_program_head = 1')
  end

  def validate_email
    return true if email.blank?

    return true if !email.nil? && email.match?(/\A\w([^@\s,;]+)@(([\w-]+\.)+(.*))\z/i)

    errors.add(:email, 'is invalid')
    false
  end

  def update_last_reminder_at(new_datetime)
    update_attribute(:last_reminder_at, new_datetime)
  end

  def reminder_email_authorized?
    return ((DateTime.now.to_time - last_reminder_at.to_time) / 60 / 60) > 24 if last_reminder_at

    true
  end

  def status=(new_status)
    errors.add(:status, 'Invalid status.') unless STATUS.include? new_status

    return if new_status == self[:status]

    self[:status] = new_status
    case new_status
    when 'pending'
      self.approved_at = nil
      self.rejected_at = nil
    when 'approved'
      self.approved_at = Time.zone.now
      self.rejected_at = nil
    when 'rejected'
      self.rejected_at = Time.zone.now
      self.approved_at = nil
    end
  end

  def email=(new_email)
    new_email_stripped = new_email.strip
    return if new_email_stripped == self[:email]

    self[:email] = new_email_stripped

    new_access_id = DirectoryService.get_accessid_by_email(new_email_stripped)

    self.access_id = new_access_id if lionpath_updated_at.blank? || is_program_head || external_to_psu_id.present?
    return unless committee_member_token.blank? && access_id.blank?

    token = CommitteeMemberToken.new authentication_token: SecureRandom.urlsafe_base64(nil, false)
    self.committee_member_token = token
    committee_member_token.save!
  end

  def committee_role_id=(new_committee_role_id)
    return if new_committee_role_id.blank? || (new_committee_role_id == self[:committee_role_id])

    self[:committee_role_id] = new_committee_role_id

    self[:is_voting] = true unless CommitteeRole.find(new_committee_role_id).name == 'Special Signatory' ||
                                   CommitteeRole.find(new_committee_role_id).is_program_head
    self[:is_voting] = false if CommitteeRole.find(new_committee_role_id).name == 'Special Signatory' ||
                                CommitteeRole.find(new_committee_role_id).is_program_head
  end

  def name=(new_name)
    super(new_name.strip)
  end

  def core_committee_member?
    !(is_program_head || (self == submission.advisor && current_partner.graduate?))
  end

  private

    def one_head_of_program_check
      return true unless committee_role.present? && submission.present? && is_program_head

      program_head = CommitteeMember.program_head(submission)
      head_committee_member_id = program_head&.id
      return true if (head_committee_member_id.nil? || head_committee_member_id == self[:id]) &&
                     (submission.committee_members.collect { |n| n.committee_role.present? ? n.is_program_head : nil }
                     .count(true) < 2)

      errors.add(:committee_role_id, 'A submission may only have one Program Head/Chair.')
      false
    end

    def validate_status
      return true if approver_controller.blank?

      return true if status.present?

      errors.add(:status, 'You must select whether you approve or reject before submitting your review.')
      false
    end

    def validate_federal_funding_used
      return true if approver_controller.blank? || !current_partner.graduate?

      errors.add(:federal_funding_confirmation, I18n.t('graduate.federal_funding_admin.error_message_2').html_safe) if federal_funding_used && federal_funding_confirmation != 'true' && status == 'approved'
      return true unless federal_funding_used.nil? && (self == submission.advisor)

      errors.add(:federal_funding_used, 'You must indicate if federal funding was utilized for this submission.')
      false
    end

    def validate_notes
      return true if approver_controller.blank?

      return true unless status == 'rejected' && notes.blank?

      errors.add(:notes, 'You must include an explanation for rejection in the "Notes for Student" form.')
      false
    end
end
