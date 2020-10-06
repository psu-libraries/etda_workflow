class TitlePageFile < ApplicationRecord
  mount_uploader :asset, PdfFileUploader

  belongs_to :submission

  validates :submission_id, :asset, presence: true
  validates :asset, virus_free: true

  def class_name
    self.class.to_s.underscore.dasherize
  end

  def link_identifier
    self.class.to_s.underscore.split('_file').first.pluralize
  end

  def full_file_path
    WORKFLOW_BASE_PATH + 'title_page_files/' + EtdaFilePaths.new.detailed_file_path(id)
  end

  def current_location
    full_file_path + asset_identifier
  end
end
