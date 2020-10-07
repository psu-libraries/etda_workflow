module AncillaryFile
  # Shared interface for ancillary files (format review, sed, proquest, title page files)

  def class_name
    self.class.to_s.underscore.dasherize
  end

  def link_identifier
    self.class.to_s.underscore.split('_file').first.pluralize
  end

  def full_file_path
    WORKFLOW_BASE_PATH + root_files_path + EtdaFilePaths.new.detailed_file_path(id)
  end

  def current_location
    full_file_path + asset_identifier
  end

  private

  def root_files_path
    # Defined in implementation class
  end
end
