RSpec.describe 'Step 5: Collecting Final Submission Files', js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'collecting final submission files'" do
    before do
      webaccess_authorize_author
    end

    let!(:author) { current_author }
    let!(:submission) { FactoryBot.create :submission, :collecting_final_submission_files, lion_path_degree_code: 'PHD', author: author, degree: degree }
    let!(:inbound_record) { FactoryBot.create :inbound_lion_path_record, author: author }
    let!(:committee_members) { create_committee(submission) }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: false }

    context "visiting the 'Update Program Information' page" do
      it 'raises a forbidden access error' do
        visit edit_author_submission_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Provide Committee' page" do
      it 'raises a forbidden access error' do
        visit new_author_submission_committee_members_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Update Committee' page" do
      it 'raises a forbidden access error' do
        visit edit_author_submission_committee_members_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(edit_author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Upload Format Review Files' page" do
      it 'raises a forbidden access error' do
        visit author_submission_edit_format_review_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'displays the program information page' do
        visit author_submission_program_information_path(submission)
        expect(page).to have_current_path(author_submission_program_information_path(submission))
        expect(page).to have_content(submission.title)
      end
    end

    context "visiting the 'Review Committee' page" do
      it 'displays the committee information page' do
        visit author_submission_committee_members_path(submission)
        expect(page).to have_content(submission.committee_members.first.name)
        expect(page).to have_current_path(author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it 'displays the review format review files page' do
        visit author_submission_format_review_path(submission)
        expect(page).to have_content(submission.title)
        expect(page).to have_current_path(author_submission_format_review_path(submission))
      end
    end

    context "visiting the 'Upload Final Submission Files page' when using lion path records" do
      it 'loads the page without a datepicker when using lion path records' do
        visit author_submission_edit_final_submission_path(submission)
        # allow(InboundLionPathRecord).to receive(:active?).and_return(true)
        expect(page).to have_current_path(author_submission_edit_final_submission_path(submission))
        if InboundLionPathRecord.active?
          expect(page).not_to have_selector('#submission_defended_at_li')
          expect(page.find('#submission_defended_at', visible: false)).to be_truthy
          expect(page).not_to have_content('Date Defended')
        end
      end

      it 'redirects to head of program page if none exists and head is approving' do
        ApprovalConfiguration.find(approval_configuration.id).update_attribute :head_of_program_is_approving, true
        CommitteeMember.remove_committee_members(submission)
        visit author_submission_edit_final_submission_path(submission)
        expect(page).to have_current_path(author_submission_head_of_program_path(submission))
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it 'raises a forbidden access error' do
        visit author_submission_final_submission_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "when I submit the 'Upload Final Submission Files' form" do
      it 'loads the page' do
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
        expect(page).to have_content('I hereby certify that')
        check 'I agree to copyright statement'
        # check 'I agree to release agreement'
        click_button 'Submit final files for review'
        # expect(page).to have_content('successfully')
        submission.reload
        expect(submission.status).to eq 'waiting for final submission response'
        submission.reload
        expect(submission.final_submission_files_uploaded_at).not_to be_nil
        expect(WorkflowMailer.deliveries.count).to eq(1) if current_partner.graduate?
        expect(WorkflowMailer.deliveries.count).to eq(1) unless current_partner.graduate?
      end
    end

    context "when I submit the 'Upload Final Submission Files' form after committee rejection" do
      it 'proceeds to "waiting for final submission response"' do
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
        # check 'I agree to release agreement'
        click_button 'Submit final files for review'
        # expect(page).to have_content('successfully')
        submission.reload
        expect(submission.committee_members.first.status).to eq 'rejected'
        expect(submission.status).to eq 'waiting for final submission response'
        expect(submission.final_submission_files_uploaded_at).not_to be_nil
        expect(WorkflowMailer.deliveries.count).to eq(1)
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
        # check 'I agree to release agreement'
        click_button 'Submit final files for review'
        # expect(page).to have_content('successfully')
        submission.reload
        expect(submission.status).to eq 'waiting for final submission response'
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
        # check 'I agree to release agreement'
        click_button 'Submit final files for review'
        # expect(page).to have_content('successfully')
        submission.reload
        expect(submission.status).to eq 'waiting for final submission response'
        submission.reload
        expect(submission.final_submission_files_uploaded_at).not_to be_nil
      end
    end
  end
end
