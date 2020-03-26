# frozen_string_literal: true

class ApprovalConfiguration < ApplicationRecord
  belongs_to :degree_type

  validates :degree_type_id, :configuration_threshold, presence: true

  GRADUATE_CONFIGURATION = { 'dissertation' => { approval_deadline_on: Date.today, configuration_threshold: 1,
                                                 email_admins: 1, email_authors: 1, use_percentage: 0,
                                                 head_of_program_is_approving: 1 },
                             'master_thesis' => { approval_deadline_on: Date.today, configuration_threshold: 0,
                                                  email_admins: 1, email_authors: 1, use_percentage: 0,
                                                  head_of_program_is_approving: 1 } }.freeze

  HONORS_CONFIGURATION = { 'thesis' => { approval_deadline_on: Date.today, configuration_threshold: 0,
                                         email_admins: 1, email_authors: 1, use_percentage: 0,
                                         head_of_program_is_approving: 0 } }.freeze

  MILSCH_CONFIGURATION = { 'thesis' => { approval_deadline_on: Date.today, configuration_threshold: 0,
                                         email_admins: 1, email_authors: 1, use_percentage: 0,
                                         head_of_program_is_approving: 0 } }.freeze

  SSET_CONFIGURATION = { 'thesis' => { approval_deadline_on: Date.today, configuration_threshold: 0,
                                       email_admins: 1, email_authors: 1, use_percentage: 0,
                                       head_of_program_is_approving: 0 } }.freeze

  CONFIGURATIONS = { 'graduate' => ApprovalConfiguration::GRADUATE_CONFIGURATION,
                     'honors' => ApprovalConfiguration::HONORS_CONFIGURATION,
                     'milsch' => ApprovalConfiguration::MILSCH_CONFIGURATION,
                     'sset' => ApprovalConfiguration::SSET_CONFIGURATION }.freeze

  def self.seed
    ApprovalConfiguration::CONFIGURATIONS[current_partner.id].each do |degree_type, configuration|
      dt = DegreeType.find_by(slug: degree_type)
      next if dt.approval_configuration.present?

      ApprovalConfiguration.create!(degree_type_id: dt[:id],
                                    approval_deadline_on: configuration[:approval_deadline_on],
                                    configuration_threshold: configuration[:configuration_threshold],
                                    email_admins: configuration[:email_admins],
                                    email_authors: configuration[:email_authors],
                                    use_percentage: configuration[:use_percentage],
                                    head_of_program_is_approving: configuration[:head_of_program_is_approving])
    end
  end
end
