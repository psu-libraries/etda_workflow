# frozen_string_literal: true

class Semester
  SEMESTERS = [
    'Fall',
    'Spring',
    'Summer'
  ].freeze

  def self.current(today = Time.zone.today)
    year = today.year
    fall_start   = Date.new(year, 8, 16)
    summer_start = Date.new(year, 5, 16)

    season = if today >= fall_start
               "Fall"
             elsif today >= summer_start
               "Summer"
             else
               "Spring"
             end
    "#{year} #{season}"
  end
end
