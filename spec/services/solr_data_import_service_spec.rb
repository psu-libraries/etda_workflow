# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe SolrDataImportService, type: :model do
  solr_data_import_service = described_class.new

  describe '#index_submission' do
    let(:submission) { create :submission }

    before do
      stub_request(:post, "https://etda.localhost:3000/solr/update?wt=json")
        .with(
          body: /title_ssi\":\"#{submission.title}/,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.3.0'
          }
        )
        .to_return(status: 200, body: { error: false }.to_json, headers: {})
      stub_request(:post, "https://etda.localhost:3000/solr/update?wt=json")
        .with(
          body: "{\"commit\":{}}",
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.3.0'
          }
        )
        .to_return(status: 200, body: { error: false }.to_json, headers: {})
    end

    it 'sends update to solr for given submission' do
      solr_data_import_service.index_submission(submission, true)
    end
  end

  describe '#remove_submission' do
    let(:submission) { create :submission }

    before do
      stub_request(:post, "https://etda.localhost:3000/solr/update?wt=json")
        .with(
          body: /delete\":#{submission.id}/,
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.3.0'
          }
        )
        .to_return(status: 200, body: { error: false }.to_json, headers: {})
    end

    it 'sends delete to solr for given submission' do
      solr_data_import_service.remove_submission(submission)
    end
  end

  context 'when solr username and password present' do
    it 'returns solr_url' do
      allow(solr_data_import_service).to receive(:solr_username).and_return 'username'
      allow(solr_data_import_service).to receive(:solr_password).and_return 'password'
      expect(solr_data_import_service.send('solr_url')).to eq("http://username:password@etda.localhost:3000:8983/solr/graduate_core")
    end
  end

  context 'when solr username and password are not present' do
    it 'returns solr_url' do
      expect(solr_data_import_service.send('solr_url')).to eq("https://etda.localhost:3000/solr")
    end
  end

  it 'returns the core identifier' do
    expect(solr_data_import_service.send('current_core')).to eq("#{current_partner.id}_core")
  end
end
