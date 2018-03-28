class SubmissionFileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

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
    if model.class_name == 'final_submission_file'
      DestinationPath.new(model.submission).full_path_for_final_submissions
    else
      Rails.root.join(WORKFLOW_BASE_PATH, 'format_review_files')
    end
  end

  def asset_hash
    path_builder = EtdaFilePaths.new
    path_builder.detailed_file_path(model.id)
  end

  def identity_subdir
    Pathname.new('.').join(asset_prefix, asset_hash)
  end
end
