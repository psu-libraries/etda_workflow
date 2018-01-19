class LionPath::MockLionPathRecord
  # return degrees from lion path until crosswalk table is available.

  MOCK_LP_AUTHOR_RECORD = { pe_etd_comm_rsp: { employee_id: "999999999", access_id: "xxb13", pe_etd_plan_comm: [{ degree_code: "PSY_PHD", degree_descr: "Psychology (PHD)", intend_grad_date: "FA 2017", defense_date: "2016-10-09", degr_chkout_stat: "", pe_etd_committee: [{ first_name: "Sandra", middle_initial: "T", last_name: "Azar", role_desc: "Chair of Committee", role_code: "C", email: "LIONPATH-TEST@PSU.EDU" }, { first_name: "Michael", middle_initial: "D", last_name: "Shapiro", role_desc: "Major Field Member", role_code: "M", email: "LIONPATH-TEST@PSU.EDU" }, { first_name: "Kisha", middle_initial: "S", last_name: "Jones", role_desc: "Major Field Member", role_code: "M", email: "LIONPATH-TEST@PSU.EDU" }, { first_name: "Kultegin", middle_initial: "", last_name: "Aydin", role_desc: "Outside Unit & Field Member", role_code: "UF", email: "LIONPATH-TEST@PSU.EDU" }] }, { degree_code: "CHEM_MS", degree_descr: "Chemistry (MS)", intend_grad_date: "FA 2024", defense_date: "", degr_chkout_stat: "", pe_etd_committee: [{ first_name: "Herman", middle_initial: "G", last_name: "Richey", role_desc: "Chair of Committee", role_code: "C", email: "LIONPATH-TEST@PSU.EDU" }, { first_name: "David", middle_initial: "D", last_name: "Boehr", role_desc: "Major Field Member", role_code: "M", email: "LIONPATH-TEST@PSU.EDU" }, { first_name: "Danny", middle_initial: "G", last_name: "Sykes", role_desc: "Major Field Member", role_code: "M", email: "LIONPATH-TEST@PSU.EDU" }] }] } }.freeze

  def self.current_data
    transformed = MOCK_LP_AUTHOR_RECORD.deep_transform_keys { |key| key.to_s.downcase.to_sym }
    transformed[LionPath::LpKeys::RESPONSE]
  end

  def self.first_degree_code
    LionPath::MockLionPathRecord.current_data[LionPath::LpKeys::PLAN].first[LionPath::LpKeys::DEGREE_CODE] || ''
  end

  def self.error_response
    { pe_etd_comm_fault: { emplid: "99999", err_nbr: 400, err_msg: "No valid Academic Plan " } }
  end
end
