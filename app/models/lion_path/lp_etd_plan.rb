class LionPath::LpEtdPlan
  attr_accessor :lion_path_degree_code
  attr_accessor :degree_code
  attr_accessor :etd_degree
  attr_accessor :etd_program
  #  attr_accessor :etd_semester
  #  attr_accessor :etd_year
  attr_accessor :defense_date

  def initialize(aplan)
    @ap = aplan
    @etd_degree = LionPath::Crosswalk.new.lp_to_etd_degree(@ap[LionPath::LpKeys::DEGREE_CODE]) || nil
    @etd_program = Program.find_or_create_by(name: @ap[LionPath::LpKeys::DEGREE_DESC]) || nil
  end

  def data
    { lp_degree_code: lp_degree_code.to_s, etd_degree: etd_degree_id.to_s, etd_program: etd_program_id.to_s, etd_semester: etd_semester.to_s, etd_year: etd_year.to_s, etd_program_name: etd_program_name.to_s, etd_degree_name: etd_degree_name.to_s, etd_defense_date: etd_defense_date.to_s }
  end

  def lp_degree_code
    @ap[LionPath::LpKeys::DEGREE_CODE]
  end

  def etd_degree_id
    d_id = get_id(@etd_degree)
    d_id
  end

  def etd_degree_name
    d_name = get_name(@etd_degree)
    d_name
  end

  def etd_program_id
    p_id = get_id(etd_program)
    p_id
  end

  def etd_program_name
    p_name = get_name(etd_program)
    p_name
  end

  def etd_semester
    LionPath::Crosswalk.grad_semester(@ap[LionPath::LpKeys::GRAD_DATE])
  end

  def etd_year
    LionPath::Crosswalk.grad_year(@ap[LionPath::LpKeys::GRAD_DATE])
  end

  def etd_defense_date
    @ap[LionPath::LpKeys::DEFENSE_DATE]
  end

  def etd_defense_date_time
    LionPath::Crosswalk.convert_to_datetime(@ap[LionPath::LpKeys::DEFENSE_DATE])
  end

  private

    def get_id(this_obj)
      return nil unless this_obj
      this_obj.id
    end

    def get_name(this_obj)
      return nil unless this_obj
      this_obj.name
    end
end
