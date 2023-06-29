# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'When Waiting for Format Review Response', type: :request do

  describe "When status is 'waiting for format review response'" do
    before do
      oidc_authorize_author
    end

    context "visiting the 'Author Submissions Index Page' page" do
      it 'loads the page' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get author_submissions_path
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'Program Information' page" do
      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get "/author/submissions/#{submission.id}/edit"
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'raises a forbidden access error' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get author_submission_program_information_path(submission)
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'New Committee' page" do
      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get new_author_submission_committee_members_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Update Committee' page" do
      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get edit_author_submission_committee_members_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Review Committee' page" do
      it "displays committee member show page" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get author_submission_committee_members_path(submission)
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it "loads review format review page" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get author_submission_format_review_path(submission)
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'Upload Final Submission Files' page" do
      before do
        stub_request(:get, %r{https://secure.gradsch.psu.edu/services/etd/etdPayment}).
          with(
            headers: {
            'Accept'=>'*/*',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
            }).
          to_return(status: 200, body: "\r\n    {\"data\":[{\"ETDPAYMENTFOUND\":\"Y\"}],\"error\":\"\"}\r\n    ", headers: {})
      end

      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get author_submission_edit_final_submission_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it "raises a forbidden access error" do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create :submission, :waiting_for_format_review_response, author: author
        get author_submission_final_submission_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end
  end
end
