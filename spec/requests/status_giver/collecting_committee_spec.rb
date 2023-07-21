# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Step 2: Collecting Committee status', type: :request do
  describe "When status is 'collecting committee'" do
    before do
      oidc_authorize_author
    end

    context "visiting the 'Author Submissions Index Page' page" do
      it 'loads the page' do
        get author_submissions_path
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'New Committee' page" do
      let(:response_body) do
        { "data":
          [{ "ACCESSID": "abc123", "NAME": "Test ProgHead", "ROLE": "ProgHead" },
           { "ACCESSID": "bca321", "NAME": "Test DGSPIC", "ROLE": "DGSPIC" }],
          "error": "" }.to_json
      end

      before do
        stub_request(:get, %r{https://secure.gradsch.psu.edu/services/etd/etdThDsAppr})
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'
            }
          )
          .to_return(status: 200, body: response_body, headers: {})
      end

      it "loads committee member edit page" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_committee, author:)
        get new_author_submission_committee_members_path(submission)
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'Update Committee' page" do
      it "loads committee member edit page" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_committee, author:)
        get edit_author_submission_committee_members_path(submission)
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'raises a forbidden access error' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_committee, author:)
        get "/author/submissions/#{submission.id}/program_information"
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Update Program Information' page" do
      it 'loads update program information page' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_committee, author:)
        get "/author/submissions/#{submission.id}/edit"
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'Review Committee' page" do
      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_committee, author:)
        get author_submission_committee_members_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_committee, author:)
        get author_submission_format_review_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Upload Final Submission Files' page" do
      before do
        stub_request(:get, %r{https://secure.gradsch.psu.edu/services/etd/etdPayment})
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby'
            }
          )
          .to_return(status: 200, body: "\r\n    {\"data\":[{\"ETDPAYMENTFOUND\":\"Y\"}],\"error\":\"\"}\r\n    ", headers: {})
      end

      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_committee, author:)
        get author_submission_edit_final_submission_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_committee, author:)
        get author_submission_final_submission_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end
  end
end
