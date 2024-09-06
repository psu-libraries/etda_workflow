RSpec.describe 'Submitting a final submission as an author', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  describe "When collecting final submission files", honors: true, milsch: true do
    before do
      oidc_authorize_author
      submission.federal_funding_details.update(training_support_funding: false, 
                                                other_funding: false, 
                                                training_support_acknowledged: false, 
                                                other_funding_acknowledged: false)
    end

    let!(:author) { current_author }
    let!(:submission) { FactoryBot.create :submission, :collecting_final_submission_files, lion_path_degree_code: 'PHD', author:, degree: }
    let!(:committee_members) { create_committee(submission) }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: false }

    context "when I submit the 'Upload Final Submission Files' form" do
      it 'loads the page' do
        submission.proquest_agreement = nil
        submission.proquest_agreement_at = nil
        submission.defended_at = Time.zone.yesterday
        submission.save(validate: false)
        submission.reload
        expect(submission.final_submission_files_uploaded_at).to be_nil
        visit author_submission_edit_final_submission_path(submission)
        expect(page).to have_content('Select one or more files to upload')
        expect(page).not_to have_link('Contact Support')
        select Time.zone.now.next_year.year, from: 'Graduation Year'
        select 'Spring', from: 'Semester Intending to Graduate'
        fill_in 'Abstract', with: 'A paper on stuff'
        page.find(".submission_delimited_keywords .ui-autocomplete-input").set('stuff')
        choose "submission_access_level_open_access" if current_partner.graduate?
        expect(page).to have_css('#final-submission-file-fields .nested-fields div.form-group div:first-child input[type="file"]')
        first_input_id = first('#final-submission-file-fields .nested-fields div.form-group div:first-child input[type="file"]')[:id]
        attach_file first_input_id, fixture('final_submission_file_01.pdf')
        if current_partner.graduate?
          find("#submission_federal_funding_details_attributes_training_support_funding_false").click
          find("#submission_federal_funding_details_attributes_other_funding_false").click
        else
          find('#submission_federal_funding_false').click
        end
        expect(page).to have_content('I hereby certify that')
        check 'I agree to copyright statement'
        check 'I agree to ProQuest statement' if current_partner.graduate?
        click_button 'Submit final files for review'
        submission.reload
        expect(submission.status).to eq 'waiting for advisor review' if current_partner.graduate?
        expect(submission.status).to eq 'waiting for committee review' unless current_partner.graduate?
        submission.reload
        expect(submission.federal_funding).to eq false
        expect(submission.final_submission_files_uploaded_at).not_to be_nil
        if current_partner.graduate?
          expect(WorkflowMailer.deliveries.count).to eq(2)
          expect(submission.proquest_agreement).to eq true
          expect(submission.proquest_agreement_at).to be_truthy
        end
        expect(WorkflowMailer.deliveries.count).to eq(3) if current_partner.honors?
        expect(WorkflowMailer.deliveries.count).to eq(2) if current_partner.milsch?
      end
    end

    context "when I submit the 'Upload Final Submission Files' form after committee rejection" do
      it 'proceeds to committee review stage and resets committee reviews' do
        submission.committee_members.first.update_attribute :status, 'rejected'
        submission.status = 'waiting for committee review rejected'
        submission.defended_at = Time.zone.yesterday
        submission.save(validate: false)
        submission.reload
        visit author_submission_edit_final_submission_path(submission)
        select Time.zone.now.next_year.year, from: 'Graduation Year'
        select 'Spring', from: 'Semester Intending to Graduate'
        fill_in 'Abstract', with: 'A paper on stuff'
        page.find(".submission_delimited_keywords .ui-autocomplete-input").set('stuff')
        choose "submission_access_level_open_access" if current_partner.graduate?
        expect(page).to have_css('#final-submission-file-fields .nested-fields div.form-group div:first-child input[type="file"]')
        first_input_id = first('#final-submission-file-fields .nested-fields div.form-group div:first-child input[type="file"]')[:id]
        attach_file first_input_id, fixture('final_submission_file_01.pdf')
        check 'I agree to copyright statement'
        check 'I agree to ProQuest statement' if current_partner.graduate?
        click_button 'Submit final files for review'
        submission.reload
        expect(page).to have_current_path(author_root_path)
        expect(submission.committee_members.first.status).to eq ''
        expect(submission.status).to eq 'waiting for advisor review' if current_partner.graduate?
        expect(submission.status).to eq 'waiting for committee review' unless current_partner.graduate?
        expect(submission.final_submission_files_uploaded_at).not_to be_nil
        expect(WorkflowMailer.deliveries.count).to eq(2) if current_partner.graduate?
        expect(WorkflowMailer.deliveries.count).to eq(3) if current_partner.honors?
        expect(WorkflowMailer.deliveries.count).to eq(2) if current_partner.milsch?
      end
    end

    context "when I submit the 'Upload Final Submission Files' form with multiple files" do
      it 'uploads two files' do
        submission.defended_at = Time.zone.yesterday
        submission.save(validate: false)
        submission.reload
        expect(submission.final_submission_files_uploaded_at).to be_nil
        visit author_submission_edit_final_submission_path(submission)
        expect(page).to have_content('Select one or more files to upload')
        expect(page).not_to have_link('Contact Support')
        select Time.zone.now.next_year.year, from: 'Graduation Year'
        select 'Spring', from: 'Semester Intending to Graduate'
        fill_in 'Abstract', with: 'A paper on stuff'
        page.find(".submission_delimited_keywords .ui-autocomplete-input").set('stuff')
        choose "submission_access_level_open_access" if current_partner.graduate?
        expect(page).to have_css('#final-submission-file-fields .nested-fields div.form-group div:first-child input[type="file"]')
        first_input_id = first('#final-submission-file-fields .nested-fields div.form-group div:first-child input[type="file"]')[:id]
        attach_file first_input_id, fixture('final_submission_file_01.pdf')
        click_link "Additional File"
        all('input[type="file"]').last.set(fixture('final_submission_file_01.pdf'))
        expect(page).to have_content('I hereby certify that')
        check 'I agree to copyright statement'
        check 'I agree to ProQuest statement' if current_partner.graduate?
        click_button 'Submit final files for review'
        submission.reload
        expect(submission.status).to eq 'waiting for advisor review' if current_partner.graduate?
        expect(submission.status).to eq 'waiting for committee review' unless current_partner.graduate?
        expect(submission.final_submission_files_uploaded_at).not_to be_nil
        expect(submission.final_submission_files.count).to eq(2)
        visit "/author/submissions/#{submission.id}/final_submission"
        expect(page).to have_link('final_submission_file_01.pdf')
        expect(page).to have_link('final_submission_file_01.pdf')
      end
    end

    context "when I have a legacy format review record and submit 'Upload Final Submission Files' form" do
      it 'loads the page' do
        submission.year = Time.zone.now.year.to_s
        submission.semester = 'Spring'
        submission.title = nil
        submission.format_review_legacy_id = 99
        submission.defended_at = Time.zone.yesterday
        submission.save(validate: false)
        expect(submission.final_submission_files_uploaded_at).to be_nil
        visit author_submission_edit_final_submission_path(submission)
        expect(page).to have_css '#submission_year'
        expect(page).to have_css '#submission_semester'
        expect(page).to have_css '#submission_title'
        fill_in 'Title', with: 'This has a format review legacy record'
        select Time.zone.now.next_year.year.to_s, from: 'submission[year]'
        select 'Spring', from: 'submission[semester]'
        fill_in 'Abstract', with: 'A paper on stuff'
        page.find(".submission_delimited_keywords .ui-autocomplete-input").set('stuff')
        choose "submission_access_level_open_access" if current_partner.graduate?
        expect(page).to have_css('#final-submission-file-fields .nested-fields div.form-group div:first-child input[type="file"]')
        first_input_id = first('#final-submission-file-fields .nested-fields div.form-group div:first-child input[type="file"]')[:id]
        attach_file first_input_id, fixture('final_submission_file_01.pdf')
        check 'I agree to copyright statement'
        check 'I agree to ProQuest statement' if current_partner.graduate?
        click_button 'Submit final files for review'
        submission.reload
        expect(submission.status).to eq 'waiting for advisor review' if current_partner.graduate?
        expect(submission.status).to eq 'waiting for committee review' unless current_partner.graduate?
        submission.reload
        expect(submission.final_submission_files_uploaded_at).not_to be_nil
      end
    end

    context 'when an ActiveRecord validation error occurs' do
      it 'displays error messages' do
        visit author_submission_edit_final_submission_path(submission)
        click_button 'Submit final files for review'
        within('.alert-danger') do
          expect(page).to have_content 'You must upload a Final Submission File'
          expect(page).to have_content "Abstract can't be blank"
          expect(page).to have_content "If you agree to the copyright terms, please check the box to submit"
        end
      end

      it 'displays error messages for funding acknowledgment' do
        skip('Graduate partner only') unless current_partner.graduate?
        visit author_submission_edit_final_submission_path(submission)
        find("#submission_federal_funding_details_attributes_training_support_funding_true").click
        find("#submission_federal_funding_details_attributes_training_support_acknowledged_false").click
        click_button 'Submit final files for review'
        within('.alert-danger') do
          expect(page).to have_content 'It is a federal requirement that all funding used to support research be acknowledged.'
        end
      end
    end
  end
end
