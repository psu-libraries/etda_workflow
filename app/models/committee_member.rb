# frozen_string_literal: true

class CommitteeMember < ApplicationRecord
  # This maps ldap values to one or more values needed for committee member autocomplete
  # validate :validate_committee_member
  # validate :validate_email
  validates :committee_role_id,
            :name,
            :email, presence: true, if: proc { |cm| cm.is_required }

  # :submission_id, :role, :name, :email, :is_required

  belongs_to :submission
  belongs_to :committee_role

  def self.advisors(submission)
    advisors_array = []
    submission.committee_members.each do |cm|
      advisors_array << cm if cm.role.downcase.include? I18n.t("#{current_partner.id}.committee.special_role")
    end
    advisors_array
  end

  def self.advisor_name(submission)
    advisors_array = CommitteeMember.advisors(submission)
    return '' if advisors_array.empty?
    advisors_array.first.name
  end

  # def validate_committee_member
  #   starting_count = errors.count
  #   errors.add(:name, "Name can't be blank") if name.blank?
  #   errors.add(:email, "Email can't be blank") if email.blank?
  #   errors.add(:committee_role_id, "Must choose a role") if committee_role_id.blank?
  #   starting_count == errors.count
  # end
  #
  # def validate_email
  #   return true if is_required && (name.blank? && email.blank?)
  #   return true if email =~ /\A[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info))\z/i
  #   errors.add(:email, 'Invalid email address')
  #   false
  # end

  def role
    return '' if committee_role_id.nil?
    CommitteeRole.find(committee_role_id).name
  end
end
