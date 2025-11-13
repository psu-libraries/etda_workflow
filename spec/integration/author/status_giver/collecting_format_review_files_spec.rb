RSpec.describe 'When Collecting Format Review Files', :js, type: :integration do
  require 'integration/integration_spec_helper'

  describe "When status is 'collecting format review files'" do
    before do
      oidc_authorize_author
    end

    let(:author) { current_author }
    let!(:admin) { current_admin }
    let!(:submission) { FactoryBot.create :submission, :collecting_format_review_files, author: }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: true }

    context "when I submit the 'Upload Format Review Files' form" do
      it "updates submission status to 'waiting for format review response'" do
        expect(submission.format_review_files_uploaded_at).to be_nil
        visit author_submission_edit_format_review_path(submission)
        fill_in 'Title', with: 'Test Title'
        find("#submission_federal_funding_details_attributes_training_support_funding_false").click
        find("#submission_federal_funding_details_attributes_other_funding_false").click
        expect(page).to have_content('Select one or more files to upload')
        expect(page).to have_css '#format-review-file-fields .nested-fields div.form-group div:first-child input[type="file"]'
        first_input_id = first('#format-review-file-fields .nested-fields div.form-group div:first-child input[type="file"]')[:id]
        attach_file first_input_id, file_fixture('format_review_file_01.pdf')
        click_button 'Submit files for review'
        submission.reload
        expect(submission.federal_funding).to be(false)
        expect(submission.status).to eq 'waiting for format review response'
        expect(submission.format_review_files_uploaded_at).not_to be_nil
      end

      it "displays error message if federal funding is not acknowledged" do
        visit author_submission_edit_format_review_path(submission)
        find("#submission_federal_funding_details_attributes_training_support_funding_true").click
        find("#submission_federal_funding_details_attributes_training_support_acknowledged_false").click
        click_button 'Submit files for review'
        within('.alert-danger') do
          expect(page).to have_content 'It is a federal requirement that all funding used to support research be acknowledged.'
        end
        expect(submission.status).to eq 'collecting format review files'
      end
    end
  end
end
