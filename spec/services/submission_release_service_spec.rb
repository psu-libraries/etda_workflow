require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe SubmissionReleaseService do
  let(:service) { described_class.new }

  before do
    allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(error: false)
  end

  describe '#publish' do
    context "when release_type is 'Release selected for publication'" do
      let(:release_type) { 'Release selected for publication' }

      context "when submission's access level is open_access" do
        let(:submission) do
          FactoryBot.create :submission, :waiting_for_publication_release, access_level: 'open_access'
        end

        it "changes the submission's status to 'released for publication" do
          service.publish([submission.id], DateTime.now, release_type)
          submission.reload
          expect(submission.status).to eq 'released for publication'
        end
      end

      context "when submission's access_level is restricted_to_institution" do
        let(:submission) do
          FactoryBot.create :submission, :waiting_for_publication_release, access_level: 'restricted_to_institution'
        end

        it "changes the submission's status to 'released for publication metadata only'" do
          service.publish([submission.id], DateTime.now, release_type)
          submission.reload
          expect(submission.status).to eq 'released for publication metadata only'
        end
      end

      context "when submission's access_level is restricted" do
        let(:submission) do
          FactoryBot.create :submission, :waiting_for_publication_release, access_level: 'restricted_to_institution'
        end

        it "changes the submission's status to 'released for publication metadata only" do
          service.publish([submission.id], DateTime.now, release_type)
          submission.reload
          expect(submission.status).to eq 'released for publication metadata only'
        end
      end
    end

    context "when release_type is 'Released as Open Access'" do
      let(:release_type) { 'Release as Open Access' }
      let(:submission) do
        FactoryBot.create :submission, :final_is_restricted_to_institution
      end

      it "changes the access_level to open_access and status to 'released for publication'" do
        service.publish([submission.id], DateTime.now, release_type)
        submission.reload
        expect(submission.status).to eq 'released for publication'
        expect(submission.access_level).to eq 'open_access'
      end
    end

    context 'SOLR_HOST is present' do
      let(:release_type) { 'Release as Open Access' }
      let(:submission) do
        FactoryBot.create :submission, :final_is_restricted_to_institution
      end

      it 'indexes submission individually and does not delta import' do
        ENV['SOLR_HOST'] = 'solr/host'
        stub_request(:post, "https://solr/host/solr/update?wt=json")
        expect_any_instance_of(SolrDataImportService).to receive(:index_submission)
        expect_any_instance_of(SolrDataImportService).not_to receive(:delta_import)
        service.publish([submission.id], DateTime.now, release_type)
        ENV['SOLR_HOST'] = nil
      end
    end

    context 'SOLR_HOST is not present' do
      let(:release_type) { 'Release as Open Access' }
      let(:submission) do
        FactoryBot.create :submission, :final_is_restricted_to_institution
      end

      it 'does not index submission individually and does a delta import' do
        ENV['SOLR_HOST'] = nil
        expect_any_instance_of(SolrDataImportService).not_to receive(:index_submission)
        expect_any_instance_of(SolrDataImportService).to receive(:delta_import)
        service.publish([submission.id], DateTime.now, release_type)
      end
    end
  end
end
