# frozen_string_literal: true

class FormatReviewFile < ApplicationRecord
  mount_uploader :asset, SubmissionFileUploader

  belongs_to :submission

  validates :submission_id, :asset, presence: true
  validates :asset_cache, presence: true, if: proc { |f| !f.submission.nil? && f.submission.author_edit && f.submission.status_behavior.collecting_format_review_files? }
  validates :asset, virus_free: true

  def class_name
    self.class.to_s.underscore.dasherize
  end

  def link_identifier
    self.class.to_s.underscore.split('_file').first.pluralize
  end

  def full_file_path
    # file path only
    WORKFLOW_BASE_PATH + 'format_review_files/' + EtdaFilePaths.new.detailed_file_path(id)
  end

  def current_location
    # full file path including file name
    # WORKFLOW_BASE_PATH + 'format_review_files/' + EtdaFilePaths.new.detailed_file_path(id) + asset_identifier
    full_file_path + asset_identifier
  end
end
