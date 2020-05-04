RSpec.describe 'Step 4: Waiting for Format Review Response', js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'waiting for format review response'" do
    before do
      webaccess_authorize_author
    end

    let!(:author) { current_author }
    let!(:submission) { FactoryBot.create :submission, :waiting_for_format_review_response, author: author }

    context "visiting the 'Author Submissions Index Page' page" do
      it 'loads the page' do
        visit author_submissions_path
        expect(page).to have_current_path(author_submissions_path)
        expect(page).to have_content(author.last_name)
        expect(page).to have_link('Accessibility')
      end
    end

    context "visiting the 'Program Information' page" do
      it "display committee_members page" do
        visit "/author/submissions/#{submission.id}/program_information"
        expect(page).not_to have_current_path(author_root_path)
        expect(page).not_to have_current_path("author/submissions/#{submission.id}/program_information")
        # expect(page).to have_content('You are not allowed to visit that page at this time, please contact your administrator')
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'raises a forbidden access error' do
        visit author_submission_program_information_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).not_to have_current_path(author_root_path)
        expect(page).to have_current_path(author_submission_program_information_path(submission))
      end
    end

    context "visiting the 'New Committee' page" do
      it "raises a forbidden access error" do
        visit new_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_root_path)
        expect(page).not_to have_current_path(new_author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Update Committee' page" do
      it "displays the committee_members for editing" do
        visit edit_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_root_path)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).not_to have_current_path(edit_author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Committee' page" do
      it "raises a forbidden access error" do
        visit author_submission_committee_members_path(submission)
        # expect(page).to have_content 'You have not completed the required steps to review your committee yet'
        expect(page).not_to have_current_path(author_root_path)
        expect(page).to have_current_path(author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_format_review_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).not_to have_current_path(author_root_path)
        expect(page).to have_current_path(author_submission_format_review_path(submission))
      end
    end

    context "visiting the 'Upload Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_edit_final_submission_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_final_submission_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end
  end
end
