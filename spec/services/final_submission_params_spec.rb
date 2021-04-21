require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionParams do
  describe "#call" do
    let(:params_hash) do
      {
          submission:
              {
                  title: 'New Title',
                  semester: 'Spring',
                  year: DateTime.now.year,
                  author_id: 1,
                  program_id: 1,
                  degree_id: 1,
                  allow_all_caps_in_title: true,
                  format_review_notes: 'Test',
                  admin_notes: 'Test',
                  final_submission_notes: 'Test',
                  defended_at: DateTime.now,
                  abstract: 'Test',
                  access_level: 'open_access',
                  is_printed: false,
                  has_agreed_to_terms: true,
                  has_agreed_to_publication_release: true,
                  restricted_notes: 'Test',
                  federal_funding: true,
                  proquest_agreement: true,
                  bogus: 'bogus',
                  committee_members_attributes: [],
                  format_review_files_attributes: [],
                  final_submission_files_attributes: [],
                  keywords_attributes: [],
                  invention_disclosures_attributes: []
              }
      }
    end
    it "returns params hash" do
      params = ActionController::Parameters.new(params_hash)
      params_hash[:submission].except! :bogus
      expect(FinalSubmissionParams.call(params).to_hash).to eq params_hash[:submission].stringify_keys
    end
  end
end
