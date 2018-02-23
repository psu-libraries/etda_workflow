class SubmissionFileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file
  add_config :base_dir
  self.base_dir = Rails.root.join('uploads')

  def store_dir
    base_dir.join(identity_subdir)
  end

  def cache_dir
    base_dir.join('cache', identity_subdir)
  end

  def asset_hash
    path_builder = EtdaFilePaths.new
    path_builder.detailed_file_path(model.id)
  end

  def identity_subdir
    Pathname.new('.').join(model.id.to_s, asset_hash, model.id.to_s)
  end
end
