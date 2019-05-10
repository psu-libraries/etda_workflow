# frozen_string_literal: true

class ApprovalConfiguration < ApplicationRecord
  belongs_to :degree_type

  validates :degree_type_id, presence: true

  GRADUATE_CONFIGURATION = { 'dissertation' => { approval_deadline_on: Date.today, rejections_permitted: 0, email_admins: 0, email_authors: 0 },
                             'master_thesis' => { approval_deadline_on: Date.today, rejections_permitted: 0, email_admins: 0, email_authors: 0 } }.freeze

  HONORS_CONFIGURATION = { 'thesis' => { approval_deadline_on: Date.today, rejections_permitted: 0, email_admins: 0, email_authors: 0 } }.freeze

  MILSCH_CONFIGURATION = { 'thesis' => { approval_deadline_on: Date.today, rejections_permitted: 0, email_admins: 0, email_authors: 0 } }.freeze

  CONFIGURATIONS = { 'graduate' => ApprovalConfiguration::GRADUATE_CONFIGURATION, 'honors' => ApprovalConfiguration::HONORS_CONFIGURATION, 'milsch' => ApprovalConfiguration::MILSCH_CONFIGURATION }.freeze

  def self.seed
    ApprovalConfiguration::CONFIGURATIONS[current_partner.id].each do |degree_type, configuration|
      dt = DegreeType.find_by(slug: degree_type)
      ac = dt.approval_configuration
      ac.update_attributes(degree_type_id: dt[:id],
                           approval_deadline_on: configuration[:approval_deadline_on],
                           rejections_permitted: configuration[:rejections_permitted],
                           email_admins: configuration[:email_admins],
                           email_authors: configuration[:email_authors])
    end
  end
end
