# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe ProgramChairCollectionService do
  let(:pcc_service) { described_class.new(submission) }
  let(:submission) { create :submission, program: program, campus: 'UP' }
  let(:program) { create :program, code: 'CODE' }
  let(:proghead_role) do
    submission.degree_type.committee_roles.where(name: 'Program Head/Chair').first
  end
  let(:dgspic_role) do
    submission.degree_type.committee_roles.where(name: 'Professor in Charge/Director of Graduate Studies').first
  end

  before do
    stub_request(:get, "https://secure.gradsch.psu.edu/services/etd/etdThDsAppr.cfm?academicPlan=CODE&campus=UP")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: body, headers: {})
  end

  context 'when a single program head is returned from webservice call' do
    let(:body) do
      {
        "data":
            [{ "ACCESSID": "abc123", "NAME": "Test ProgHead", "ROLE": "ProgHead" }],
        "error": ""
      }.to_json
    end

    it 'returns a collection array with program head info' do
      expect(pcc_service.collection).to eq [
        ["Test ProgHead (Program Head)",
         "Test ProgHead",
         { committee_role_id: proghead_role.id,
           member_email: "abc123@psu.edu" }]
      ]
    end
  end

  context 'when a program head and professor in charge is returned from webservice call' do
    let(:body) do
      {
        "data":
            [{ "ACCESSID": "abc123", "NAME": "Test ProgHead", "ROLE": "ProgHead" },
             { "ACCESSID": "cba321", "NAME": "Test DGSPIC", "ROLE": "DGSPIC" }],
        "error": ""
      }.to_json
    end

    it 'returns a collection array with program head and professor in charge info' do
      expect(pcc_service.collection).to eq [
        ["Test ProgHead (Program Head)",
         "Test ProgHead",
         { committee_role_id: proghead_role.id,
           member_email: "abc123@psu.edu" }],
        ["Test DGSPIC (Professor in Charge)",
         "Test DGSPIC",
         { committee_role_id: dgspic_role.id,
           member_email: "cba321@psu.edu" }]
      ]
    end
  end

  context 'when an error is returned from webservice call' do
    let(:body) do
      {
        "data":
            [{ "ETDTHDSAPPROVAL": "Error" }],
        "error": "Approver Not Found"
      }.to_json
    end

    it 'raises a RuntimeError' do
      allow(Rails.logger).to receive(:error).with(/Approver Not Found/).once
      expect { pcc_service.collection }.to raise_error(RuntimeError, 'Approver Not Found')
    end
  end

  context 'when a connection error is raised' do
    before do
      allow(HTTParty).to receive(:get).and_raise Net::ReadTimeout
    end

    it 'logs the error and raises an error' do
      allow(Rails.logger).to receive(:error).with(/Net::ReadTimeout/).once
      expect { pcc_service.collection }.to raise_error Net::ReadTimeout
    end
  end
end
