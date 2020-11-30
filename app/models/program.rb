# frozen_string_literal: true

class Program < ApplicationRecord
  has_many :submissions
  has_many :program_chairs

  validates :name, presence: true
  validates :name, uniqueness: { scope: :code, case_sensitive: true }

  after_initialize :set_is_active_to_true

  DEFAULT_NAMES = ["Aerospace Engineering (AERSP)", "Architectural Engineering (AE)",
                   "Astronomy and Astrophysics (ASTRO)", "Biochemistry and Molecular Biology (BMB)",
                   "Biological Engineering (BME)", "Biology (BIOL)", "Biomedical Engineering (BME)",
                   "Biotechnology (BIOTC)", "Chemical Engineering (CHE)", "Chemistry (CHEM)", "Civil Engineering (CE)",
                   "Computer Engineering (CMPEN)", "Computer Science (CMPSC)", "Data Sciences (DATSC)",
                   "Electrical Engineering (EE)", "Engineering Science (ESC)", "Industrial Engineering (IE)",
                   "Mechanical Engineering (ME)", "Microbiology (MICRB)", "Nuclear Engineering (NUCE)", "Physics (PYS)",
                   "Planetary Science and Astronomy (PASTR)", "Statistics (STAT)"].freeze

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

    DEFAULT_NAMES.each do |program|
      find_or_create_by!(name: program.to_s) do |record|
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
