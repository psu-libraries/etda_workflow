RSpec.describe "Last Step: 'waiting for publication release'", js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'waiting for publication release'" do
    before do
      webaccess_authorize_author
      webaccess_authorize_admin
      submission.degree.degree_type.approval_configuration = approval_configuration
    end

    let!(:author) { current_author }
    let!(:admin) { current_admin }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, author: author, degree: degree }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration }

    context "visiting the 'Author Submissions Index Page' page" do
      it 'loads the page' do
        visit author_submissions_path
        expect(page).to have_current_path(author_submissions_path)
        expect(page).to have_content(author.last_name)
        expect(page).to have_link('Accessibility')
      end
    end

    context "visiting the 'Update Program Information' page" do
      it "raises a forbidden access error" do
        visit edit_author_submission_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Provide Committee' page" do
      it "raises a forbidden access error" do
        visit new_author_submission_committee_members_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Update Committee' page" do
      before { visit edit_author_submission_committee_members_path(submission) }

      it "raises a forbidden access error" do
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Upload Format Review Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_edit_format_review_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Program Information' page" do
      it "loads the page" do
        visit author_submission_program_information_path(submission)
        expect(page).to have_current_path(author_submission_program_information_path(submission))
      end
    end

    context "visiting the 'Review Committee' page" do
      it "loads the page" do
        visit author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it "loads the page" do
        visit author_submission_format_review_path(submission)
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
      it "loads the page" do
        visit author_submission_final_submission_path(submission)
        expect(page).to have_current_path(author_submission_final_submission_path(submission))
      end
    end
  end
end
