# frozen_string_literal: true

class CommitteeMember < ApplicationRecord
  class ProgramHeadMissing < StandardError; end

  # This maps ldap values to one or more values needed for committee member autocomplete
  validate :validate_email
  validates :committee_role_id,
            :name,
            :email, presence: true

  belongs_to :submission
  belongs_to :committee_role
  belongs_to :approver, optional: true
  has_one :committee_member_token, dependent: :destroy

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
    @submission = Submission.find(submission_id)
    CommitteeMember.where(submission: @submission).find_by(committee_role: CommitteeRole.find_by(name: 'Program Head/Chair', degree_type: @submission.degree.degree_type))
  end

  def validate_email
    ldap_result = LdapUniversityDirectory.new.autocomplete(name).first
    ldap_result.present? ? ldap_email_result = ldap_result[:id].to_s : ldap_email_result = nil
    return true if email.blank?

    unless email.nil? || (is_required == true && ldap_email_result.blank?) || (is_required == true && ldap_email_result != email)
      return true if email.match?(/\A[\w]([^@\s,;]+)@(([\w-]+\.)+(.*))\z/i)
    end
    errors.add(:email, 'is invalid')
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
    new_access_id = LdapUniversityDirectory.new.retrieve_committee_access_id(new_email)
    self.access_id = new_access_id if new_access_id.present?
  end

  def committee_role_id=(new_committee_role_id)
    return if new_committee_role_id.blank?

    self[:committee_role_id] = new_committee_role_id
    self[:is_voting] = true unless CommitteeRole.find(new_committee_role_id).name == 'Special Signatory' || CommitteeRole.find(new_committee_role_id).name == 'Program Head/Chair'
    self[:is_voting] = false if CommitteeRole.find(new_committee_role_id).name == 'Special Signatory' || CommitteeRole.find(new_committee_role_id).name == 'Program Head/Chair'
    return unless (CommitteeRole.find(new_committee_role_id).name == 'Special Member' || CommitteeRole.find(new_committee_role_id).name == 'Special Signatory') && committee_member_token.blank?

    token = CommitteeMemberToken.new authentication_token: SecureRandom.urlsafe_base64(nil, false)
    self.committee_member_token = token
    committee_member_token.save!
  end
end
