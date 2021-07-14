# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe SolrDataImportService, type: :model do
  solr_data_import_service = described_class.new

  it 'returns solr_url' do
    expect(solr_data_import_service.send('solr_url')).to eq(this_url)
  end
  it 'returns delta-import params' do
    expect(solr_data_import_service.send('delta_import_params')).to eq('command' => 'delta-import', 'clean' => false)
  end

  it 'returns full-import params' do
    expect(solr_data_import_service.send('full_import_params')).to eq('command' => 'full-import', 'clean' => true)
  end

  it 'returns dataimport core' do
    expect(solr_data_import_service.send('dataimport')).to eq("#{current_partner.id}_core/dataimport")
  end

  it 'checks whether solr is still processing a transaction' do
    result = { 'status' => 'busy' }
    expect(solr_data_import_service.send('solr_is_busy?', result)).to be_truthy
    result = { 'status' => 'idle' }
    expect(solr_data_import_service.send('solr_is_busy?', result)).to be_falsey
  end

  it 'returns the core identifier' do
    expect(solr_data_import_service.send('current_core')).to eq("#{current_partner.id}_core")
  end

  it 'updates solr using delta_import' do
    delta_params = { 'command' => 'delta-import', 'clean' => false }
    solr = solr_data_import_service.send('solr')
    solr_result = { error: false, solr_result: { "responseHeader" => { "status" => 0, "QTime" => 2 }, "initArgs" => ["defaults", ["config", "db-data-config.xml"]], "command" => "delta-import", "status" => "idle", "importResponse" => "", "statusMessages" => { "Total Requests made to DataSource" => "8", "Total Rows Fetched" => "0", "Total Documents Processed" => "0", "Total Documents Skipped" => "0", "Delta Dump started" => "2018-07-19 21:37:30", "Identifying Delta" => "2018-07-19 21:37:30", "Deltas Obtained" => "2018-07-19 21:37:30", "Building documents" => "2018-07-19 21:37:30", "Total Changed Documents" => "0", "Time taken" => "0:0:0.354" } } }
    allow(solr_data_import_service).to receive(:execute_cmd).with(delta_params).and_return(solr_result)
    allow(solr).to receive(:get).with("#{current_partner.id}_core/dataimport", delta_params).and_return(solr_result)
    expect(solr_data_import_service.delta_import).to eq(solr_result)
  end

  it 'updates solr using full_import' do
    full_import_params = { 'command' => 'full-import', 'clean' => true }
    solr = solr_data_import_service.send('solr')
    solr_result = { error: false, solr_result: { "responseHeader" => { "status" => 0, "QTime" => 3 }, "initArgs" => ["defaults", ["config", "db-data-config.xml"]], "command" => "full-import", "status" => "idle", "importResponse" => "", "statusMessages" => { "Total Requests made to DataSource" => "184627", "Total Rows Fetched" => "294916", "Total Documents Processed" => "13245", "Total Documents Skipped" => "0", "Full Dump Started" => "2018-07-19 22:27:01", "" => "Indexing completed. Added/Updated: 13245 documents. Deleted 0 documents.", "Committed" => "2018-07-19 22:30:38", "Time taken" => "0:3:36.204" } } }
    allow(solr_data_import_service).to receive(:execute_cmd).with(full_import_params).and_return(solr_result)
    allow(solr).to receive(:get).with("#{current_partner.id}_core/dataimport", full_import_params).and_return(solr_result)
    expect(solr_data_import_service.full_import).to eq(solr_result)
  end

  it 'executes command and returns an error' do
    solr = solr_data_import_service.send('solr')
    error_result = { :error => true, "statusMessages" => { "" => "An error occurred! Check the log messages for more information" } }
    allow(solr).to receive(:get).with("#{current_partner.id}_core/dataimport", params: {"clean" => false, "command" => 'delta-import'}).and_return(error_result)
    expect(solr_data_import_service.send('execute_cmd', 'command' => 'delta-import', 'clean' => false)).to eql(error_result)
  end

  def this_url
    EtdUrls.new.explore + '/solr'
  end
end
