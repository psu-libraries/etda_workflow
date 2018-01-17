# frozen_string_literal: true

class Program < ApplicationRecord
  has_many :submissions

  validates :name, presence: true,
                   uniqueness: true

  after_initialize :set_is_active_to_true

  def active_status
    is_active ? 'Yes' : 'No'
  end

  private

  def set_is_active_to_true
    self.is_active = true if new_record? && is_active.nil?
  end
end
