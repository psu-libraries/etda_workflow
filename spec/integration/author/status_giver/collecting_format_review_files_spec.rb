RSpec.describe 'Step 3: Collecting Format Review Files', js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'collecting format review files'" do
    before do
      oidc_authorize_author
    end

    let!(:author) { current_author }
    let!(:admin)  { current_admin }
    let!(:submission) { FactoryBot.create :submission, :collecting_format_review_files, author: }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: true }

    context "visiting the 'Author Submissions Index Page' page" do
      it 'loads the page' do
        visit author_submissions_path
        expect(page).to have_current_path(author_submissions_path)
        expect(page).to have_content(author.last_name)
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'displays program information page for review' do
        visit author_submission_program_information_path(submission)
        expect(page).to have_current_path(author_submission_program_information_path(submission))
      end
    end

    context "visiting the 'New Committee' page" do
      it "raises a forbidden access error" do
        visit new_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Update Committee' page" do
      it "displays the committee_members for editing" do
        visit edit_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(edit_author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Committee' page" do
      it "raises a forbidden access error" do
        visit author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_format_review_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Upload Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_edit_final_submission_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_final_submission_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "when I submit the 'Upload Format Review Files' form" do
      it "updates submission status to 'waiting for format review response'" do
        expect(submission.format_review_files_uploaded_at).to be_nil
        visit author_submission_edit_format_review_path(submission)
        fill_in 'Title', with: 'Test Title'
        find("#submission_federal_funding_true").click
        expect(page).to have_content('Select one or more files to upload')
        expect(page).to have_css '#format-review-file-fields .nested-fields div.form-group div:first-child input[type="file"]'
        first_input_id = first('#format-review-file-fields .nested-fields div.form-group div:first-child input[type="file"]')[:id]
        attach_file first_input_id, fixture('format_review_file_01.pdf')
        click_button 'Submit files for review'
        # expect(page).to have_content('successfully')
        submission.reload
        expect(submission.federal_funding).to eq true
        expect(submission.status).to eq 'waiting for format review response'
        expect(submission.format_review_files_uploaded_at).not_to be_nil
      end
    end
  end
end
