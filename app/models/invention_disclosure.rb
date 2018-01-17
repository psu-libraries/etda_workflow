# frozen_string_literal: true

class InventionDisclosure < ApplicationRecord
  belongs_to :submission

  def self.description
    'The Restricted option should be used exclusively for authors with patent issues.  Authors using this option are required to file an Invention Disclosure form with the Intellectual Property Office in order to obtain an Invention Disclosure Number.'.html_safe
  end

  def self.prefix_range
    8
  end
end
