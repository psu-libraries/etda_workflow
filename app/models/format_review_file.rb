# frozen_string_literal: true

class FormatReviewFile < ApplicationRecord
  mount_uploader :asset, SubmissionFileUploader

  belongs_to :submission

  validates :submission_id, :asset, presence: true
  validates :asset_cache, presence: true, if: proc { |f| !f.submission.nil? && f.submission.author_edit && f.submission.status_behavior.collecting_format_review_files? }
  validates :asset, virus_free: true

  include AncillaryFile

  private

  def root_files_path
    'format_review_files/'
  end
end
