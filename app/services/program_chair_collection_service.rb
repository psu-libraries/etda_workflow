class ProgramChairCollectionService
  def initialize(submission)
    @submission = submission
  end

  def collection
    collection = []
    gpms_response.each do |pc|
      collection << ["#{pc['NAME']} (#{committee_role_name(pc['ROLE'])})",
                     (pc['NAME']).to_s,
                     { member_email: (pc["ACCESSID"].downcase.to_s + '@psu.edu'),
                       committee_role_id: committee_role_id(pc["ROLE"]) }]
    end
    collection
  end

  private

    attr_accessor :submission

    def committee_role_name(role)
      if role == 'DGSPIC'
        'Professor in Charge'
      else
        'Program Head'
      end
    end

    def committee_role_id(role)
      if role == 'DGSPIC'
        submission.degree_type.committee_roles.where(name: 'Professor in Charge/Director of Graduate Studies').first.id
      else
        submission.degree_type.committee_roles.where(name: 'Program Head/Chair').first.id
      end
    end

    def gpms_response
      begin
        JSON(HTTParty.get(gpms_prog_chair_url, verify: false).parsed_response)["data"]
      rescue Net::ReadTimeout, Net::OpenTimeout, SocketError => e
        Rails.logger.error e.message
        raise e
      end
    end

    def gpms_prog_chair_url
      "https://secure.gradsch.psu.edu/services/etd/etdThDsAppr.cfm" + query
    end

    def query
      "?academicPlan=#{program_code}&campus=#{campus}"
    end

    def campus
      submission.campus
    end

    def program_code
      submission.program.code
    end
end
