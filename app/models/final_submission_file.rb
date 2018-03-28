# frozen_string_literal: true

class FinalSubmissionFile < ApplicationRecord
  mount_uploader :asset, SubmissionFileUploader

  validates :submission_id, :asset, presence: true
  validates :asset, virus_free: true

  belongs_to :submission

  def class_name
    self.class.to_s.underscore.dasherize
  end

  def link_identifier
    self.class.to_s.underscore.split('_file').first.pluralize
  end
end
