# frozen_string_literal: true

class FinalSubmissionFile < ApplicationRecord
  mount_uploader :asset, SubmissionFileUploader

  belongs_to :submission

  has_one :remediated_final_submission_file, dependent: :destroy

  validates :submission_id, :asset, presence: true
  validates :asset, virus_free: true

  # file must be moved to correct path after the final_submission_file id has been created
  # move file to the correct path; needed to upload to released or partially released submissions
  after_save :move_file

  # delete the file from the correct path
  before_destroy :delete_file

  def class_name
    self.class.to_s.underscore.dasherize
  end

  def link_identifier
    self.class.to_s.underscore.split('_file').first.pluralize
  end

  def current_location
    # full file path including file name
    main_file_path + file_detail_path + asset_identifier
  end

  def full_file_path
    # file path w/o file name
    main_file_path + file_detail_path
  end

  def file_detail_path
    # partial unique path built from file id -- ie('/01/01/')
    EtdaFilePaths.new.detailed_file_path(id)
  end

  def main_file_path
    # base portion of path up to file_detail_path
    SubmissionFilePath.new(submission).full_path_for_final_submissions
  end

  def pdf?
    asset.content_type == 'application/pdf'
  end

  private

    def move_file
      # for released file, move to the correct location after upload
      return unless submission.status_behavior.released_for_publication?

      path_builder = EtdaFilePaths.new
      original_file_location = "#{WORKFLOW_BASE_PATH}final_submission_files/#{path_builder.detailed_file_path(id)}#{asset_identifier}"
      path_builder.move_a_file(id, original_file_location, file_class: self.class)
    end

    def delete_file
      return unless submission.status_behavior.released_for_publication?

      FileUtils.rm current_location
    end
end
