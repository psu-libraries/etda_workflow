# frozen_string_literal: true

class Degree < ApplicationRecord
  belongs_to :degree_type
  has_many :submissions

  validates :name,
            :description,
            :degree_type_id,
            presence: true

  validates :name, uniqueness: true

  after_initialize :set_is_active_to_true

  GRADUATE_DEGREES = {
    dissertation: [
      { name: "DED", description: "Doctor of Education" },
      { name: "DMA", description: "Doctor of Musical Arts" },
      { name: "DNP", description: "Doctor of Nursing Practice" },
      { name: "DrPH", description: "Doctor of Public Health" },
      { name: "PHD", description: "Doctor of Philosophy" }
    ],
    master_thesis: [
      { name: "MA", description: "Master of Arts" },
      { name: "MS", description: "Master of Science" }
    ]
  }.freeze

  HONORS_DEGREES = {
    thesis: [
      { name: "B A", description: "Bachelor of Arts" },
      { name: "B AE", description: "Bachelor of Architectural Engineering" },
      { name: "B DES", description: "Bachelor of Design" },
      { name: "B F A", description: "Bachelor of Fine Arts" },
      { name: "B L A", description: "Bachelor of Landscape Architecture" },
      { name: "B M", description: "Bachelor of Music" },
      { name: "B M E", description: "Bachelor of Music Education" },
      { name: "B P", description: "Bachelor of Philosophy" },
      { name: "B S", description: "Bachelor of Science" },
      { name: "B. HUM", description: "Bachelor of Humanities" },
      { name: "BARCH", description: "Bachelor of Architecture" }
    ]
  }.freeze

  MILSCH_DEGREES = {
    thesis: [
      { name: "B S", description: "Bachelor of Science" }
    ]
  }.freeze

  SSET_DEGREES = {
    thesis: [
      { name: "ME", description: "Master of Engineering" }
    ]
  }.freeze

  DEGREES = { graduate: GRADUATE_DEGREES, honors: HONORS_DEGREES, milsch: MILSCH_DEGREES, sset: SSET_DEGREES }.freeze

  def self.seed
    DEGREES[current_partner.id.to_sym].each do |degree_type, degrees|
      degrees.each do |degree|
        Degree.find_or_create_by!(name: degree[:name].to_s) do |record|
          next if record.persisted?

          record[:description] = degree[:description]
          record[:is_active] = true
          record[:degree_type_id] = DegreeType.find_by(slug: degree_type.to_s).id
        end
      end
    end
  end

  def active_status
    is_active ? 'Yes' : 'No'
  end

  # problem when DB is empty; fails on migration
  def self.valid_degrees_list
    list = []
    Degree.all.find_each do |degree|
      list << degree.slug if degree.is_active?
    end
    list
  end

  def self.etd_degree_slug(degree_id)
    degree = Degree.find(degree_id)
    degree.slug
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def slug
    name.upcase.tr(' ', '_')
  end

  private

  def set_is_active_to_true
    self.is_active = true if new_record? && is_active.nil?
  end
end
