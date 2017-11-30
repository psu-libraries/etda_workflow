class Degree < ApplicationRecord
  belongs_to :degree_type
  has_many :submissions

  validates :name,
            :description,
            :degree_type_id,
            presence: true

  validates :name, uniqueness: true

  after_initialize :set_is_active_to_true

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
    return nil
  end

  def slug
    name.upcase.tr(' ', '_')
  end

  private

    def set_is_active_to_true
      self.is_active = true if self.new_record? && is_active.nil?
    end
end
