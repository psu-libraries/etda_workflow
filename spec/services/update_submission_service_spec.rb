# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe UpdateSubmissionService do
  let(:service) { described_class.new }
  let(:submission) { FactoryBot.create :submission, :released_for_publication }

  describe '#solr_delta_update' do
    context 'when SOLR_HOST is present' do
      it 'indexes submission' do
        ENV['SOLR_HOST'] = 'solr/host'
        stub_request(:post, "https://solr/host/solr/update?wt=json")
        expect_any_instance_of(SolrDataImportService).to receive(:index_submission).and_return({})
        expect_any_instance_of(SolrDataImportService).not_to receive(:delta_import)
        service.solr_delta_update(submission)
        ENV['SOLR_HOST'] = nil
      end
    end

    context 'when SOLR_HOST is not present' do
      it 'runs delta import' do
        ENV['SOLR_HOST'] = nil
        expect_any_instance_of(SolrDataImportService).not_to receive(:index_submission)
        expect_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return({})
        service.solr_delta_update(submission)
      end
    end
  end
end
