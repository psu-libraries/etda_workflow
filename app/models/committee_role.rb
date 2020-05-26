# frozen_string_literal: true

class CommitteeRole < ApplicationRecord
  belongs_to :degree_type
  has_many :committee_members

  GRADUATE_ROLES = { 'dissertation' => [
    { name: 'Program Head/Chair', num_required: 1, is_active: true },
    { name: 'Dissertation Advisor/Co-Advisor', num_required: 1, is_active: true },
    { name: 'Committee Chair/Co-Chair', num_required: 1, is_active: true },
    { name: 'Committee Member', num_required: 2, is_active: true },
    { name: 'Outside Member', num_required: 1, is_active: true },
    { name: 'Special Member', num_required: 0, is_active: true },
    { name: 'Special Signatory', num_required: 0, is_active: true }
  ],
                     'master_thesis' => [
                       { name: 'Program Head/Chair', num_required: 1, is_active: true },
                       { name: 'Thesis Advisor/Co-Advisor', num_required: 1, is_active: true },
                       { name: 'Committee Member', num_required: 0, is_active: true },
                       { name: 'Special Signatory', num_required: 0, is_active: true }
                     ] }.freeze

  HONORS_ROLES = { 'thesis' => [
    { name: 'Thesis Supervisor',       num_required: 1, is_active: true },
    { name: 'Honors Advisor',          num_required: 1, is_active: true },
    { name: 'Faculty Reader',          num_required: 0, is_active: true }
  ] }.freeze

  MILSCH_ROLES = { 'thesis' => [
    { name: 'Thesis Supervisor', num_required: 1, is_active: true },
    { name: 'Advisor',           num_required: 0, is_active: true },
    { name: 'Honors Advisor',    num_required: 0, is_active: true }
  ] }.freeze

  SSET_ROLES = { 'thesis' => [
    { name: 'Thesis Supervisor', num_required: 1, is_active: true },
    { name: 'Advisor',           num_required: 0, is_active: true },
    { name: 'Honors Advisor',    num_required: 0, is_active: true }
  ] }.freeze

  ROLES = { 'graduate' => CommitteeRole::GRADUATE_ROLES, 'honors' => CommitteeRole::HONORS_ROLES,
            'milsch' => CommitteeRole::MILSCH_ROLES, 'sset' => CommitteeRole::SSET_ROLES }.freeze

  def self.seed
    CommitteeRole::ROLES[current_partner.id].each do |degree_type, roles|
      dt = DegreeType.find_by(slug: degree_type)
      roles.each do |r|
        dt.committee_roles.find_or_create_by!(name: r[:name]) do |new_committee_role|
          new_committee_role.num_required = r[:num_required]
          new_committee_role.is_active = r[:is_active]
        end
      end
    end
  end

  def self.add_lp_role(cm_role)
    CommitteeRole.create(name: cm_role.strip, num_required: 0, is_active: true, degree_type_id: DegreeType.default.id)
  end

  def self.advisor_role
    # special_role_name = I18n.t("#{current_partner.id}.committee.special_role")
    # hardcoding until locales file is added
    special_role_name = 'advisor'
    role = CommitteeRole.find_by("name LIKE '%#{special_role_name}'")
    role.id || nil
  end

  def possible_committee_roles(degree_type)
      degree_type.try(&:committee_roles).order('name asc') || []
  end
end
