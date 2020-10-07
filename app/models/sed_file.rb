class SedFile < ApplicationRecord
  mount_uploader :asset, AncillaryPdfUploader

  belongs_to :submission

  validates :submission_id, :asset, presence: true
  validates :asset, virus_free: true

  include AncillaryFile

  private

  def root_files_path
    'sed_files/'
  end
end
