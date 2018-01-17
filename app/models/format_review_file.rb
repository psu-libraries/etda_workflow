# frozen_string_literal: true

class FormatReviewFile < ApplicationRecord
  # mount_uploader :asset, SubmissionFileUploader

  validates :submission_id, :asset, presence: true
  # validates :asset, virus_free: true

  belongs_to :submission

  def class_name
    self.class.to_s.underscore.dasherize
  end
end
