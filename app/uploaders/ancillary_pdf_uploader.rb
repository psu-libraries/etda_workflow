class AncillaryPdfUploader < CarrierWave::Uploader::Base
  storage :file
  add_config :base_dir

  self.base_dir = Rails.root

  def store_dir
    base_dir.join(identity_subdir)
  end

  def cache_dir
    base_dir.join('cache', identity_subdir)
  end

  def asset_prefix
    if model.class_name == 'proquest-file'
      Rails.root.join(WORKFLOW_BASE_PATH, 'proquest_files')
    elsif model.class_name == 'sed-file'
      Rails.root.join(WORKFLOW_BASE_PATH, 'sed_files')
    else
      Rails.root.join(WORKFLOW_BASE_PATH, 'title_page_files')
    end
  end

  def asset_hash
    path_builder = EtdaFilePaths.new
    path_builder.detailed_file_path(model.id)
  end

  def identity_subdir
    Pathname.new('.').join(asset_prefix, asset_hash)
  end

  def content_type_whitelist
    ['application/pdf']
  end

  def extension_whitelist
    %w[pdf]
  end
end
