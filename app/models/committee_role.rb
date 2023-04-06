# frozen_string_literal: true

class CommitteeRole < ApplicationRecord
  belongs_to :degree_type
  has_many :committee_members

  # With the addition of the LionPATH integration, these graduate dissertation roles are no longer in use
  # The preferred dissertation roles are imported during the LionPATH import
  # However, these roles still exist for legacy submissions
  GRADUATE_ROLES = { 'dissertation' => [
                       { name: 'Program Head/Chair', num_required: 1, is_active: true, is_program_head: true },
                       { name: 'Professor in Charge/Director of Graduate Studies', num_required: 0,
                         is_active: true, is_program_head: true },
                       { name: 'Dissertation Advisor/Co-Advisor', num_required: 0, is_active: true, is_program_head: false },
                       { name: 'Committee Chair/Co-Chair', num_required: 0, is_active: true, is_program_head: false },
                       { name: 'Committee Member', num_required: 0, is_active: true, is_program_head: false },
                       { name: 'Outside Member', num_required: 0, is_active: true, is_program_head: false },
                       { name: 'Special Member', num_required: 0, is_active: true, is_program_head: false },
                       { name: 'Special Signatory', num_required: 0, is_active: true, is_program_head: false }
                     ],
                     'master_thesis' => [
                       { name: 'Program Head/Chair', num_required: 1, is_active: true, is_program_head: true },
                       { name: 'Professor in Charge/Director of Graduate Studies', num_required: 0,
                         is_active: true, is_program_head: true },
                       { name: 'Thesis Advisor/Co-Advisor', num_required: 1, is_active: true, is_program_head: false },
                       { name: 'Committee Member', num_required: 1, is_active: true, is_program_head: false },
                       { name: 'Special Signatory', num_required: 0, is_active: true, is_program_head: false }
                     ] }.freeze

  HONORS_ROLES = { 'thesis' => [
    { name: 'Thesis Supervisor',       num_required: 1, is_active: true, is_program_head: false },
    { name: 'Honors Advisor',          num_required: 1, is_active: true, is_program_head: false },
    { name: 'Thesis Honors Advisor',   num_required: 0, is_active: true, is_program_head: false },
    { name: 'Faculty Reader',          num_required: 0, is_active: true, is_program_head: false }
  ] }.freeze

  MILSCH_ROLES = { 'thesis' => [
    { name: 'Thesis Supervisor', num_required: 1, is_active: true, is_program_head: false },
    { name: 'Advisor',           num_required: 0, is_active: true, is_program_head: false },
    { name: 'Honors Advisor',    num_required: 0, is_active: true, is_program_head: false }
  ] }.freeze

  SSET_ROLES = { 'final_paper' => [
    { name: 'Paper Instructor (Advisor)', num_required: 1, is_active: true, is_program_head: false },
    { name: 'Paper Reader',               num_required: 1, is_active: true, is_program_head: false },
    { name: 'Department Head',            num_required: 1, is_active: true, is_program_head: true }
  ] }.freeze

  ROLES = { 'graduate' => CommitteeRole::GRADUATE_ROLES, 'honors' => CommitteeRole::HONORS_ROLES,
            'milsch' => CommitteeRole::MILSCH_ROLES, 'sset' => CommitteeRole::SSET_ROLES }.freeze

  def self.seed
    CommitteeRole::ROLES[current_partner.id].each do |degree_type, roles|
      dt = DegreeType.find_by(slug: degree_type)
      roles.each do |r|
        cr = dt.committee_roles.find_or_create_by!(name: r[:name], degree_type: dt) do |new_committee_role|
          new_committee_role.num_required = r[:num_required]
          new_committee_role.is_active = r[:is_active]
          new_committee_role.is_program_head = r[:is_program_head]
        end
        next unless cr.persisted?

        cr.update(num_required: r[:num_required], is_active: r[:is_active], is_program_head: r[:is_program_head])
      end
    end
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
