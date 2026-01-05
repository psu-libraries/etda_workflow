class RemediatedFinalSubmissionFile < ApplicationRecord
  mount_uploader :asset, SubmissionFileUploader

  belongs_to :submission
  belongs_to :final_submission_file

  validates :submission_id, :asset, presence: true
  validates :asset, virus_free: true

  def class_name
    self.class.to_s.underscore.dasherize
  end
end
