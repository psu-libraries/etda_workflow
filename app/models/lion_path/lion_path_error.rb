class LionPath::LionPathError
  def initialize(lp_record, access_id)
    @lp_error = lp_record[LionPath::LpKeys::ERROR_RESPONSE]
    @lp_access_id = access_id
  end

  def error_msg
    lp_error_code = @lp_error[LionPath::LpKeys::ERR_CODE].to_s
    lp_error_msg = @lp_error[LionPath::LpKeys::ERR_MSG]
    msg = 'Lion Path Error: ' + lp_error_code.to_s + ' -- ' + "#{lp_error_msg} for Access Id: #{@lp_access_id}"
    msg
  end

  def log_error
    Rails.logger.info error_msg
  end
end
