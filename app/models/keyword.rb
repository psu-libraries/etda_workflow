# frozen_string_literal: true

class Keyword < ApplicationRecord
  validates :submission_id, :word, presence: true, allow_blank: false

  belongs_to :submission

  def self.hint
    "Enter keywords in the following box.  Multiple keywords can be entered and one keyword entry may contain multiple words.  Use a comma to separate keyword entries. To delete a keyword, click the 'X' or use the backspace key."
  end
end
