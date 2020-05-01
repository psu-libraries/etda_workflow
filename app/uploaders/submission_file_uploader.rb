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

  def content_type_blacklist
    ['application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
     'application/vnd.ms-word.document.macroEnabled.12', 'application/vnd.ms-word.template.macroEnabled.12',
     'application/vnd.openxmlformats-officedocument.wordprocessingml.template']
  end

  def extension_blacklist
    %w[dotx dotm docx doc docm dot]
  end

  # private
  #
  #   def move_file(_file)
  #     # the file cannot be moved here when
  #     # uploading released submissions
  #     # ******** this doesn't work bc file.id is empty so extended file path cannot be calculated
  #     return unless model.submission.status_behavior.released_for_publication?
  #     original_file_location = Rails.root.join(identity_subdir, asset_identifier)
  #     EtdaFilePaths.new.move_a_file(model.id, original_file_location)
  #   end
end
