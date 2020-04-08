# frozen_string_literal: true

class DegreeType < ApplicationRecord
  has_many :committee_roles
  has_many :degrees
  has_many :submissions, through: :degrees
  has_one :approval_configuration

  default_scope { order(:name) }

  NAMES = {
    'graduate' => [
      "Dissertation",
      "Master Thesis"
    ],
    'honors' => [
      "Thesis"
    ],
    'milsch' => [
      "Thesis"
    ],
    'sset' => [
      "Thesis"
    ]
  }.freeze

  def self.default
    first
  end

  def self.seed
    NAMES[current_partner.id].each do |name|
      find_or_create_by!(slug: name.parameterize.underscore) do |new_degree|
        new_degree.name = name
      end
    end
  end

  def to_s
    name
  end

  def to_param
    slug
  end

  delegate :to_sym, to: :slug

  def required_committee_roles
    required_roles = []
    committee_roles.select(&:is_active).each do |cr|
      cr.num_required.times do
        required_roles << cr
      end
    end
    required_roles
  end
end
