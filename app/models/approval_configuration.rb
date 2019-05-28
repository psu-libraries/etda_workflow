# frozen_string_literal: true

class ApprovalConfiguration < ApplicationRecord
  belongs_to :degree_type

  validates :degree_type_id, presence: true

  GRADUATE_CONFIGURATION = { 'dissertation' => { approval_deadline_on: Date.today, rejections_permitted: 0, email_admins: 0, email_authors: 0, use_percentage: 0, percentage_for_approval: 100 },
                             'master_thesis' => { approval_deadline_on: Date.today, rejections_permitted: 0, email_admins: 0, email_authors: 0, use_percentage: 0, percentage_for_approval: 100 } }.freeze

  HONORS_CONFIGURATION = { 'thesis' => { approval_deadline_on: Date.today, rejections_permitted: 0, email_admins: 0, email_authors: 0, use_percentage: 0, percentage_for_approval: 100 } }.freeze

  MILSCH_CONFIGURATION = { 'thesis' => { approval_deadline_on: Date.today, rejections_permitted: 0, email_admins: 0, email_authors: 0, use_percentage: 0, percentage_for_approval: 100 } }.freeze

  CONFIGURATIONS = { 'graduate' => ApprovalConfiguration::GRADUATE_CONFIGURATION, 'honors' => ApprovalConfiguration::HONORS_CONFIGURATION, 'milsch' => ApprovalConfiguration::MILSCH_CONFIGURATION }.freeze

  def self.seed
    ApprovalConfiguration::CONFIGURATIONS[current_partner.id].each do |degree_type, configuration|
      dt = DegreeType.find_by(slug: degree_type)
      next if dt.approval_configuration.present?

      ApprovalConfiguration.create!(degree_type_id: dt[:id],
                                    approval_deadline_on: configuration[:approval_deadline_on],
                                    rejections_permitted: configuration[:rejections_permitted],
                                    email_admins: configuration[:email_admins],
                                    email_authors: configuration[:email_authors])
    end
  end
end
