class LionPath::Crosswalk
  LP_SEMESTER = { FA: 'Fall', SP: 'Spring', SU: 'Summer' }.freeze
  LP_ACCESS = { open_access: 'OPEN', restricted_to_institution: 'RPSU', restricted: 'RSTR' }.freeze

  def self.convert_to_datetime(date_in)
    return '' if date_in.blank?
    date_time = date_in
    Date.strptime(date_time, LionPath::LpFormats::DEFENSE_DATE_FORMAT).to_time
  rescue ArgumentError
    ''
  end

  def self.grad_semester(graduation_date)
    lp_semester = graduation_date.split(' ').first.to_sym
    LP_SEMESTER[lp_semester]
  rescue StandardError
    ''
  end

  def self.grad_year(graduation_date)
    graduation_date.split(' ').last
  rescue StandardError
    ''
  end

  def self.etd_to_lp_access(access_level)
    return 'OPEN' if access_level.blank?
    LP_ACCESS[access_level.to_sym] || 'OPEN'
  end

  def lp_to_etd_degree(degree_code)
    degree_type = degree_code_type(degree_code)
    etd_degree = Degree.where(name: degree_type)
    return nil if etd_degree.nil?
    etd_degree.first
  end

  private

    def degree_code_type(degree_code)
      return '' if degree_code.nil?
      return('M ED') if degree_code.last(5) == '_M_ED'
      degree_code.split('_').last
    end
end
