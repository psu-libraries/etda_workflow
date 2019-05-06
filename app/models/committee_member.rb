# frozen_string_literal: true

class CommitteeMember < ApplicationRecord
  # This maps ldap values to one or more values needed for committee member autocomplete
  validate :validate_committee_member
  validate :validate_email
  validates :committee_role_id,
            :name,
            :email, presence: true, if: proc { |cm| cm.is_required }

  belongs_to :submission
  belongs_to :committee_role

  STATUS = ["pending", "approved", "rejected"].freeze

  def self.advisors(submission)
    advisors_array = []
    submission.committee_members.each do |cm|
      advisors_array << cm if cm.committee_role.name.downcase.include? I18n.t("#{current_partner.id}.committee.special_role")
    end
    advisors_array
  end

  def self.advisor_name(submission)
    advisors_array = CommitteeMember.advisors(submission)
    return '' if advisors_array.empty?

    advisors_array.first.name
  end

  def self.remove_committee_members(submission)
    submission.committee_members.each(&:destroy)
    submission.save
  end

  def self.current_committee(submission_id)
    CommitteeMember.where(submission_id: submission_id).pluck(:committee_role_id, :is_required, :name, :email)
  end

  def self.head_of_program(submission_id)
    CommitteeMember.where(submission_id: submission_id).find_by(committee_role_id: CommitteeRole.find_by(name: 'Head/Chair of Graduate Program'), is_required: true)
  end

  def validate_committee_member
    starting_count = errors.count
    errors.add(:name, "Name can't be blank") if name.blank?
    errors.add(:email, "Email can't be blank") if email.blank?
    errors.add(:committee_role_id, "Must choose a role") if committee_role_id.blank?
    starting_count == errors.count
  end

  def validate_email
    return true if is_required && (name.blank? && email.blank?)

    unless email.nil?
      return true if email.match?(/\A[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info))\z/i)
    end
    errors.add(:email, 'Invalid email address')
    false
  end

  def update_last_reminder_at(new_datetime)
    update_attribute(:last_reminder_at, new_datetime)
  end

  def reminder_email_authorized?
    if last_reminder_at
      ((DateTime.now.to_time - last_reminder_at.to_time) / 60 / 60) > 24
    else
      true
    end
  end

  def status=(new_status)
    self[:status] = new_status
    case new_status
    when nil || ""
      self.approval_started_at = nil
      self.approved_at = nil
      self.rejected_at = nil
      self.reset_at = Time.zone.now
    when 'pending'
      self.approval_started_at = Time.zone.now
      self.approved_at = nil
      self.rejected_at = nil
    when 'approved'
      self.approval_started_at = Time.zone.now
      self.approved_at = Time.zone.now
      self.rejected_at = nil
    when 'rejected'
      self.approval_started_at = Time.zone.now
      self.rejected_at = Time.zone.now
      self.approved_at = nil
    end
  end

  def email=(new_email)
    self[:email] = new_email
    self.access_id = email.gsub('@psu.edu', '').strip if email.match?(/.*@psu.edu/)
  end
end
