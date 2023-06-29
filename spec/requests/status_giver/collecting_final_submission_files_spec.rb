# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Step 5: Collecting Final Submission Files', type: :request do
  describe "When status is 'collecting final submission files'" do
    before do
      oidc_authorize_author
    end

    context "visiting the 'Update Program Information' page" do
      it 'raises a forbidden access error' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
        get edit_author_submission_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Provide Committee' page" do
      it 'raises a forbidden access error' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
        get new_author_submission_committee_members_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Update Committee' page" do
      it 'displays the update committee page' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
        get edit_author_submission_committee_members_path(submission)
        expect(response.code).to eq "200"
      end
    end

    context "visiting the 'Upload Format Review Files' page" do
      it 'raises a forbidden access error' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
        get author_submission_edit_format_review_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'displays the program information page' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
        get author_submission_program_information_path(submission)
        expect(response.code).to eq "200"
        expect(response.body).to match(/#{submission.title}/)
      end
    end

    context "visiting the 'Review Committee' page" do
      it 'raises a forbidden access error' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
        get author_submission_committee_members_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it 'displays the review format review files page' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
        get author_submission_format_review_path(submission)
        expect(response.code).to eq "200"
        expect(response.body).to match(/#{submission.title}/)
      end
    end

    context "visiting the 'Upload Final Submission Files page'" do
      context 'when current_partner is graduate' do
        before do
          skip 'Graduate Only' unless current_partner.graduate?
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

        context 'when student has paid their fee' do
          it 'displays the upload final submission files page' do
            author = Author.find_by access_id: 'authorflow'
            submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
            get author_submission_edit_final_submission_path(submission)
            expect(response.code).to eq "200"
          end
        end

        context 'when an error is encountered' do
          before do
            WebMock.reset!
            stub_request(:get, /https:\/\/secure.gradsch.psu.edu\/services\/etd\/etdPayment.cfm/).to_timeout
          end

          it 'redirects to the author root page and displays flash' do
            author = Author.find_by access_id: 'authorflow'
            submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
            get author_submission_edit_final_submission_path(submission)
            expect(response.code).to eq "302"
            expect(response.redirect_url).to eq(author_root_url)
            expect(flash.alert).to match(/An error occurred while processing your request/)
          end
        end
      end

      context 'when current_partner is not graduate', honors: true, sset: true, milsch: true do
        before do
          skip 'Non-graduate Only' if current_partner.graduate?
        end

        it 'displays the upload final submission files page' do
          author = Author.find_by access_id: 'authorflow'
          submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
          get author_submission_edit_final_submission_path(submission)
          expect(response.code).to eq "200"
        end
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it 'raises a forbidden access error' do
        author = Author.find_by access_id: 'authorflow'
        submission = FactoryBot.create(:submission, :collecting_final_submission_files, author:)
        get author_submission_final_submission_path(submission)
        expect(response.code).to eq "302"
        expect(response.redirect_url).to eq(author_root_url)
      end
    end
  end
end
