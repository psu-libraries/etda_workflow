# frozen_string_literal: true

class Program < ApplicationRecord
  has_many :submissions

  validates :name, presence: true
  validates :name, uniqueness: { scope: :code, case_sensitive: true }

  after_initialize :set_is_active_to_true

  # Programs are imported from LionPATH during the LIonPATH import
  # These defaults can be used to set up the development env
  DEFAULT_NAMES = {
    "Public Administration (PHD)" => "PADM_PHD",
    "Chemistry (PHD)" => "CHEM_PHD",
    "Mechanical Engineering (PHD)" => "ME_PHD",
    "Comparative Literature (PHD)" => "CMLIT_PHD",
    "Sociology (PHD)" => "SOC_PHD",
    "Physics (PHD)" => "PHYS_PHD",
    "Anthropology (PHD)" => "ANTH_PHD",
    "Electrical Engineering (PHD)" => "EE_PHD",
    "Mechanical Engineering (MS)" => "ME_MS",
    "Information Science (MS)" => "INSC_MS",
    "Nutritional Sciences (MS)" => "NUTR_MS",
    "Spatial Data Science (MS)" => "SDS_MS",
    "Anatomy (MS)" => "ANAT_MS",
    "Animal Science (MS)" => "ANSC_MS",
    "Plant Pathology (MS)" => "PPATH_MS",
    "Aerospace Engineering (MS)" => "AERSP_MS"
  }.freeze

  # Seeds for development.
  # These values can be changed by admins, so running this seed in production may interfere with their changes.
  # Can be used when initializing a new partner.
  def self.seed
    if current_partner.sset?
      find_or_create_by(name: "WC Electrical Engineering") do |record|
        record.is_active = true unless record.persisted?
      end
      return
    end

    DEFAULT_NAMES.each_pair do |program, code|
      find_or_create_by!(name: program.to_s) do |record|
        record.code = code
        record.is_active = true unless record.persisted?
      end
    end
  end

  def active_status
    is_active ? 'Yes' : 'No'
  end

  private

    def set_is_active_to_true
      self.is_active = true if new_record? && is_active.nil?
    end
end
