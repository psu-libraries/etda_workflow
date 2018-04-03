# frozen_string_literal: true

class EtdaFilePaths < EtdaUtilities::EtdaFilePaths
  def workflow_base_path
    WORKFLOW_BASE_PATH
  end

  def explore_base_path
    EXPLORE_BASE_PATH
  end

  def this_host
    Rails.application.secrets.webaccess[:path] + '/'
  end

  def move_a_file(fid, original_file_location)
    updated_file = FinalSubmissionFile.find(fid)
    # this is calculating the new location based on updated submission and file attributes

    new_location = updated_file.new_location_path
    # create file path if it doesn't exist
    FileUtils.mkpath(new_location)

    # file path + file name
    new_file_location = new_location + updated_file.asset_identifier
    FileUtils.mv(original_file_location, new_file_location) unless new_file_location == original_file_location
  end
end
