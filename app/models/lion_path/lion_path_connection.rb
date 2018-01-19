class LionPath::LionPathConnection
  def retrieve_student_information(psu_idn, _access_id)
    # result = RestClient.get('https://etdeht:XXXXXX@test-ib1.lionpath.psu.edu/PSIGW/RESTListeningConnector/PSFT_HR/PE_ETD_EMPLID_COMMITTEE.v1', params: {employee_id: '99999999', access_id: '' })
    # Do not log URL
    Rails.logger.silence do
      result = RestClient.get(lionpath_query_string.to_s, params: { employee_id: psu_idn.to_s })
      obj = JSON.parse(result.body).deep_transform_keys { |key| key.to_s.downcase.to_sym }
      obj
    end
  end

  def send_thesis_update(thesis_params, thesis_detail)
    # Rails.logger.silence do
    # thesis_detail = '{"PE_ETD_THESIS_REQ1": {"PE_ETD_THESIS": [{"degree_code": "CI_MS","thesis_title": "Testing CI_MS 2/10 by svk3","thesis_status": "Waiting for format review response","thesis_status_date": "2017-02-01","access_level": "OPEN","embargo_start_date": "2016-01-01","embargo_end_date": "2016-12-31"}]}}'

    result = RestClient.put(lionpath_thesis_url.to_s, thesis_detail, params: thesis_params, content_type: :json, accept: :json)
    obj = JSON.parse(result.body)
    obj
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.info e.response.inspect
    e.response

    # end
  end

  private

    def lionpath_base_url
      "https://#{lionpath_user}:#{lionpath_pwd}@test-ib1.lionpath.psu.edu/PSIGW/RESTListeningConnector/PSFT_HR/"
    end

    def lionpath_query_string
      CGI.escape("https://#{lionpath_user}:#{lionpath_pwd}@test-ib1.lionpath.psu.edu/PSIGW/RESTListeningConnector/PSFT_HR/PE_ETD_EMPLID_COMMITTEE.v1")
    end

    def lionpath_thesis_url
      CGI.escape("https://#{lionpath_user}:#{lionpath_pwd}@test-ib1.lionpath.psu.edu/PSIGW/RESTListeningConnector/PSFT_HR/PE_ETD_STUDENT_INFO.v1")
    end

    def lionpath_user
      Rails.application.config_for(:lion_path)[:username]
    end

    def lionpath_pwd
      Rails.application.config_for(:lion_path)[:password]
    end
end
