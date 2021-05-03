class ProgramChair < ApplicationRecord
  belongs_to :program

  def self.roles
    ["Department Head", "Professor in Charge"].freeze
  end

  validates :role, presence: true, inclusion: { in: ProgramChair.roles }
end
