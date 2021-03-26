# frozen_string_literal: true

class Semester
  SEMESTERS = [
    'Fall',
    'Spring',
    'Summer'
  ].freeze

  def self.current
    season = if today >= fall_start
               "Fall"
             elsif today >= summer_start
               "Summer"
             else
               "Spring"
             end
    "#{year} #{season}"
  end

  def self.last
    season = if today >= fall_start
               "Summer"
             elsif today >= summer_start
               "Spring"
             else
               "Fall"
             end

    if season == "Fall"
      "#{year - 1} #{season}"
    else
      "#{year} #{season}"
    end
  end

  def self.all_years
    this_year = Time.zone.today.year
    Semester.new.build_year_list(1998, this_year + 10)
  end

  def self.graduation_years
    this_year = Time.zone.today.year
    list = Semester.new.build_year_list(this_year - 10, this_year + 10)
    list.reverse
  end

  def build_year_list(start_year, end_year)
    years = []
    end_year.downto(start_year) { |yr| years << yr }
    years
  end

  private

  def valid_semester?(current_semester, this_semester)
    # all semesters valid during spring and current semester is always OK for the current year
    return true if current_semester == 'Spring' || current_semester == this_semester

    # during summer may choose summer or fall for the current year
    return true if current_semester == 'Summer' && this_semester == 'Fall'

    false
  end

  def self.today
    Time.zone.today
  end

  def self.year
    today.year
  end

  def self.fall_start
    Date.new(year, 8, 16)
  end

  def self.summer_start
    Date.new(year, 5, 16)
  end
end
