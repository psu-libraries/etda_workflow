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

  def self.all_years
    this_year = Time.zone.today.year
    Semester.new.build_year_list(1998, this_year + 3)
  end

  def self.graduation_years
    this_year = Time.zone.today.year
    list = Semester.new.build_year_list(this_year, this_year + 5)
    list.reverse
  end

  def build_year_list(start_year, end_year)
    years = []
    end_year.downto(start_year) { |yr| years << yr }
    years
  end
end
