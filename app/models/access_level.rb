# frozen_string_literal: true

class AccessLevel < EtdaUtilities::AccessLevel
  def self.display
    @display ||= build_display_array
  end

  def self.build_display_array
    display_array = []
    AccessLevel.paper_access_levels.each do |alevel|
      display_array.push(alevel) unless alevel[:type] == ""
    end
    display_array
  end
end
