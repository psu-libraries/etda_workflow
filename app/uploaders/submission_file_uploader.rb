class SubmissionFileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  #### does not work; model.id is not available after :store, :move_file

  storage :file
  add_config :base_dir

  self.base_dir = Rails.root

  def move_to_cache
    return false if Rails.env.test?

    true
  end

  def move_to_store
    return false if Rails.env.test?

    true
  end

  def store_dir
    base_dir.join(identity_subdir)
  end

  def cache_dir
    base_dir.join('cache', identity_subdir)
  end

  def asset_prefix
    if model.class_name == 'final-submission-file'
      Rails.root.join(WORKFLOW_BASE_PATH, 'final_submission_files')
    elsif model.class_name == 'admin-feedback-file'
      Rails.root.join(WORKFLOW_BASE_PATH, 'admin_feedback_files')
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

  def content_type_allowlist
    ['application/pdf',
     'application/txt', 'text/plain',
     'image/jpg', 'image/jpeg', 'image/png', 'image/gif',
     'audio/mp3', 'audio/wav', 'video/mov', 'video/mp4', 'application/zip']
  end

  def extension_allowlist
    %w[pdf txt jpg jpeg png gif mp3 wav mov mp4 zip]
  end
end
