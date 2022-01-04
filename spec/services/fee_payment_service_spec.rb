require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FeePaymentService do
  let(:service) { described_class.new(submission) }
  let!(:submission) { create :submission }

  context "when the student's fee has been paid" do
    context "when the submission degree_type is Dissertation" do
      it 'returns true' do
        stub_request(:get, "https://secure.gradsch.psu.edu/services/etd/etdPayment.cfm?degree=PHD&psuid=#{submission.author.psu_idn}")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'
            }
          )
          .to_return(status: 200, body: "\r\n    {\"data\":[{\"ETDPAYMENTFOUND\":\"Y\"}],\"error\":\"\"}\r\n    ", headers: {})
        expect(service.fee_is_paid?).to eq true
      end
    end

    context "when the submission degree_type is Master Thesis" do
      it 'returns true' do
        submission.degree.degree_type = DegreeType.find_by(name: 'Master Thesis')
        submission.save!
        stub_request(:get, "https://secure.gradsch.psu.edu/services/etd/etdPayment.cfm?degree=MS&psuid=#{submission.author.psu_idn}")
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'
            }
          )
          .to_return(status: 200, body: "\r\n    {\"data\":[{\"ETDPAYMENTFOUND\":\"Y\"}],\"error\":\"\"}\r\n    ", headers: {})
        expect(service.fee_is_paid?).to eq true
      end
    end
  end

  context "when the student's fee has not been paid" do
    it 'raises FeeNotPaid error' do
      stub_request(:get, "https://secure.gradsch.psu.edu/services/etd/etdPayment.cfm?degree=PHD&psuid=#{submission.author.psu_idn}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: "\r\n    {\"data\":[{\"ETDPAYMENTFOUND\":\"N\"}],\"error\":\"\"}\r\n    ", headers: {})
      expect { service.fee_is_paid? }.to raise_error FeePaymentService::FeeNotPaid
    end
  end

  context "when the gradsch API returns an error" do
    it 'raises StandardError error' do
      stub_request(:get, "https://secure.gradsch.psu.edu/services/etd/etdPayment.cfm?degree=PHD&psuid=#{submission.author.psu_idn}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: "\r\n    {\"data\":[{\"ETDPAYMENTFOUND\":\"Error\"}],\"error\":\"Invalid Parameters\"}\r\n    ", headers: {})
      expect { service.fee_is_paid? }.to raise_error StandardError
    end
  end

  context "when request times out" do
    it 'raises Net::OpenTimeout error' do
      stub_request(:get, "https://secure.gradsch.psu.edu/services/etd/etdPayment.cfm?degree=PHD&psuid=#{submission.author.psu_idn}")
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'Ruby'
          }
        ).to_timeout
      expect { service.fee_is_paid? }.to raise_error Net::OpenTimeout
    end
  end
end
