class FeePaymentService
  class FeeNotPaid < StandardError; end

  def initialize(submission)
    @submission = submission
  end

  def fee_is_paid?
    begin
      result = JSON.parse(HTTParty.get(full_url, verify: false).parsed_response)
    rescue Net::ReadTimeout, Net::OpenTimeout, SocketError => e
      Rails.logger.error e.message
      raise e
    end
    if result["data"].first["ETDPAYMENTFOUND"].to_s == "Y"
      true
    elsif result["data"].first["ETDPAYMENTFOUND"].to_s == "N"
      raise FeeNotPaid
    else
      raise result["error"].to_s
    end
  end

  private

    def full_url
      base_url + query
    end

    def base_url
      "https://secure.gradsch.psu.edu/services/etd/etdPayment.cfm"
    end

    def query
      "?psuid=#{author_psu_idn}&degree=#{degree_name}"
    end

    def author_psu_idn
      submission.author.psu_idn
    end

    def degree_name
      submission.degree.name
    end

    attr_accessor :submission
end
