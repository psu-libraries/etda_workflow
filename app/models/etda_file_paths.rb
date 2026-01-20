# frozen_string_literal: true

class EtdaFilePaths < EtdaUtilities::EtdaFilePaths
  def workflow_base_path
    WORKFLOW_BASE_PATH
  end

  def explore_base_path
    EXPLORE_BASE_PATH
  end

  # file_class injection options: [FinalSubmissionFile, RemediatedFinalSubmissionFile]
  def move_a_file(fid, original_file_location, file_class: FinalSubmissionFile)
    error_msg = ''

    unless File.exist?(original_file_location)
      error_msg = "File not found: #{original_file_location}"
      Rails.logger.error(error_msg)
      return error_msg
    end

    updated_file = file_class.find(fid)
    # this is calculating the new location based on updated submission and file attributes

    new_location = updated_file.full_file_path
    # create file path if it doesn't exist
    FileUtils.mkpath(new_location)

    # file path + file name
    new_file_location = new_location + updated_file.asset_identifier
    FileUtils.mv(original_file_location, new_file_location) unless new_file_location == original_file_location
    error_msg
  rescue StandardError => e
    Rails.logger.error("Error moving file from #{original_file_location}")
    Rails.logger.error("Actual Error message: #{e}")
    e
  end
end
