# frozen_string_literal: true

class FacultyMember < ApplicationRecord
  has_many :committee_members

  validates :webaccess_id,
            :first_name,
            :last_name, presence: true

  validates :webaccess_id, uniqueness: { case_sensitive: true }
end
