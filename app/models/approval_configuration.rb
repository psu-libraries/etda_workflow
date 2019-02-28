# frozen_string_literal: true

class ApprovalConfiguration < ApplicationRecord
  belongs_to :degree_type

  validates :degree_type_id, presence: true
end
