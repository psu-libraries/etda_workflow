class LionPath::LpKeys
  RESPONSE = :pe_etd_comm_rsp
  ACCESS_ID = :access_id
  EMPLOYEE_ID = :employee_id

  ERROR_RESPONSE = :pe_etd_comm_fault
  ERR_CODE = :err_nbr
  ERR_MSG = :err_msg

  PLAN = :pe_etd_plan_comm
  DEGREE_CODE = :degree_code
  DEGREE_DESC = :degree_descr
  GRAD_DATE = :intend_grad_date
  DEFENSE_DATE = :defense_date
  DEGREE_CHECKOUT = :degree_chkout_stat

  COMMITTEE = :pe_etd_committee
  FIRST_NAME = :first_name
  MIDDLE_NAME = :middle_initial
  LAST_NAME = :last_name
  ROLE_CODE = :role_code
  ROLE_DESC = :role_desc
  EMAIL = :email
end

class LionPath::LpFormats
  DEFENSE_DATE_FORMAT = '%Y-%m-%d'.freeze
end
