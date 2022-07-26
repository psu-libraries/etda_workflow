require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe SubmissionReleaseService do
  let(:service) { described_class.new }

  before do
    stub_request(:post, "https://etda.localhost:3000/solr/update?wt=json")
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

    it 'indexes submission' do
      release_type = 'Release as Open Access'
      submission = FactoryBot.create :submission, :final_is_restricted_to_institution
      expect_any_instance_of(SolrDataImportService).to receive(:index_submission)
      service.publish([submission.id], DateTime.now, release_type)
    end
  end
end
