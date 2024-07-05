# frozen_string_literal: true

class AdminFeedbackFile < ApplicationRecord
  mount_uploader :asset, SubmissionFileUploader

  belongs_to :submission

  def self.FEEDBACK_TYPES
    ['format-review', 'final-submission'].freeze
  end

  validates :submission_id, :asset, presence: true
  validates :asset, virus_free: true
  validates :feedback_type, inclusion: { in: self.FEEDBACK_TYPES }, presence: true

  def class_name
    self.class.to_s.underscore.dasherize
  end

  def link_identifier
    self.class.to_s.underscore.split('_file').first.pluralize
  end

  def full_file_path
    # file path only
    "#{WORKFLOW_BASE_PATH}admin_feedback_files/#{EtdaFilePaths.new.detailed_file_path(id)}"
  end

  def current_location
    # full file path including file name
    full_file_path + asset_identifier
  end
end
