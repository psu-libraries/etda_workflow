class DestinationPath
  def initialize(submission)
    @submission = submission
  end

  def full_path_for_final_submissions
    return file_path_for_published_submissions if @submission.status_behavior.released_for_publication?
    path_builder = EtdaFilePaths.new
    path_builder.workflow_upload_final_files_path
  end

  def file_path_for_published_submissions
    path_builder = EtdaFilePaths.new
    return path_builder.explore_open if @submission.access_level.open_access?
    return path_builder.explore_psu_only if @submission.access_level.restricted_to_institution?
    path_builder.workflow_restricted
  end
end
