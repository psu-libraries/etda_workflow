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

  it 'returns current_core' do
    expect(solr_data_import_service.send('current_core')).to eq("#{current_partner.id}_core")
  end

  def this_url
    url = Rails.application.secrets.webaccess[:vservice].strip
    url.sub! 'workflow', 'explore'
    url.sub! 'http:', 'https:'
    url + '/solr'
  end
end
