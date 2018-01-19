class LionPath::MockLionPathConnection
  def initialize; end

  def with_connection; end

  def retrieve_student_information(_psu_idn, _access_id)
    obj = LionPath::MockLionPathRecord::MOCK_LP_AUTHOR_RECORD.deep_transform_keys { |key| key.to_s.downcase.to_sym }
    obj
  end
end
