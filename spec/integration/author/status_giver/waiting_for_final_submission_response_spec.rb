RSpec.describe "Step 6: Waiting for Final Submission Response'", js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'waiting for final submission response'" do
    before do
      webaccess_authorize_author
      webaccess_authorize_admin
    end

    let!(:author) { current_author }
    let!(:admin)  { current_admin }
    let!(:submission) { FactoryBot.create :submission, :waiting_for_final_submission_response, author: author, degree: degree }
    let!(:degree) { FactoryBot.create :degree }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, configuration_threshold: 0, email_authors: true, use_percentage: false, email_admins: true }
    let!(:committee_members) { [(FactoryBot.create :committee_member), (FactoryBot.create :committee_member)] }

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
      it "raises a forbidden access error" do
        visit edit_author_submission_committee_members_path(submission)
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

    context "when an admin accepts the final submission files for a submission without a Lion Path Record" do
      it "updates status to 'waiting for committee review' and emails committee members" do
        submission.committee_members << committee_members
        submission.save!
        submission.reload
        select_year = Date.current.year - 2
        select_month = 'Mar'
        select_day = '1'
        submission.author.inbound_lion_path_record = nil
        submission.final_submission_approved_at = nil
        create_committee(submission)
        FactoryBot.create :format_review_file, submission: submission
        FactoryBot.create :final_submission_file, submission: submission
        visit admin_edit_submission_path(submission)
        sleep 2
        fill_in 'Final Submission Notes to Student', with: 'Note on paper is approved'
        if current_partner.graduate?
          select select_year, from: 'submission[defended_at(1i)]'
          select select_month, from: 'submission[defended_at(2i)]'
          select select_day, from: 'submission[defended_at(3i)]'
        end
        click_button 'Approve Final Submission'
        expect(page).to have_content("The submission's final submission information was successfully approved.")
        submission.reload
        expect(submission.status).to eq 'waiting for committee review' unless current_partner.honors?
        expect(submission.status).to eq 'waiting for publication release' if current_partner.honors?
        expect(page).to have_content("The submission's final submission information was successfully approved.")
        submission.reload
        expect(submission.final_submission_approved_at).not_to be_nil
        expect(formatted_date(submission.defended_at)).to eq(formatted_date(Date.parse("#{select_year}-#{select_month}-#{select_day}"))) if current_partner.graduate?
        expect(WorkflowMailer.deliveries.count).to eq(8) unless current_partner.honors?
        expect(WorkflowMailer.deliveries.count).to eq(1) if current_partner.honors?
      end
    end

    context "when an admin accepts the final submission files for a submission with an active Lion Path Record" do
      if InboundLionPathRecord.active?
        it "updates submission status to 'waiting for committee_review'" do
          submission.status = 'collecting final submission files'
          submission.final_submission_approved_at = nil
          submission.defended_at = Time.zone.yesterday
          FactoryBot.create :format_review_file, submission: submission
          FactoryBot.create :final_submission_file, submission: submission
          create_committee(submission)
          visit admin_edit_submission_path(submission)
          sleep 2
          fill_in 'Final Submission Notes to Student', with: 'Note on paper is approved'
          if current_partner.graduate?
            expect(page.find('#defense_date').find('#submission_defended_at', visible: false)).to be_truthy
            expect(page).not_to have_selector('#submission_defended_at_li')
          end
          click_button 'Approve Final Submission'
          expect(page).to have_content("The submission's final submission information was successfully approved.")
          submission.reload
          expect(submission.status).to eq 'waiting for committee review'
          expect(page).to have_content("The submission's final submission information was successfully approved.")
          submission.reload
          expect(submission.final_submission_approved_at).not_to be_nil
          expect(submission.defended_at).to eq(Date.yesterday.in_time_zone) if current_partner.graduate?
        end
      end
    end

    context "when an admin rejects the final submission files", :glacial do
      it "updates status to 'collecting final submission files rejected'" do
        submission.status = 'collecting final submission files'
        submission.final_submission_rejected_at = nil
        submission.final_submission_approved_at = nil
        FactoryBot.create :format_review_file, submission: submission
        FactoryBot.create :final_submission_file, submission: submission
        visit admin_edit_submission_path(submission)
        fill_in 'Final Submission Notes to Student', with: 'Note on need for revisions'
        click_button 'Reject & request revisions'
        expect(page).to have_content('final submission information was successfully rejected and returned to the author for revision')
        submission.reload
        expect(submission.status).to eq 'collecting final submission files rejected'
        submission.reload
        expect(submission.final_submission_rejected_at).not_to be_nil
      end
    end
  end

  describe 'an admin deletes a format review file that is waiting for approval', js: true do
    let!(:submission) { FactoryBot.create :submission, :waiting_for_format_review_response }
    let!(:format_file) { FactoryBot.create :format_review_file, submission: submission }

    # Add after updating file controller methods for author and admin

    context 'admin deletes the format review file' do
      xit 'removes the file' do
        visit admin_edit_submission_path(submission)
        sleep 2
        find_link('[delete]').click
        expect(page).to have_no_link('[delete]', wait: Capybara.default_max_wait_time * 4)
        # visit admin_edit_submission_path(submission)
        find_link('Additional File').click
        expect(page).not_to have_content('new_admin_file.pdf')
        expect(page).to have_css '#format-review-file-fields .nested-fields:last-child input[type="file"]'
        last_input_id = first('#format-review-file-fields .nested-fields:last-child input[type="file"]')[:id]
        attach_file last_input_id, Rails.root.join('spec', 'fixtures', 'new_admin_file.pdf')
        click_button 'Update Metadata Only'
        expect(page).to have_content('Format review information was successfully edited by an administrator')
        # visit admin_edit_submission_path(submission)
        file_name = first('#format-review-file-fields .nest-fields:last-child').find('a.file-link').text
        expect(file_name).to start_with('new_admin_file.pdf')
      end
    end
  end
  # describe 'an admin deletes a final submission file that is waiting for approval', js: true do
  #   it 'deletes the file' do
  #   submission. status = 'waiting for final submission response'
  #   before do
  #     create :final_submission_file, submission: submission
  #     sleep 1.0 # adding sleep in becuase I am desparate to get travis stable...
  #     expect(submission.final_submission_files.count).to eq(1)
  #     visit admin_edit_submission_path(submission)
  #     sleep 2
  #     expect(page).to have_link('delete')
  #     click_link 'delete'
  #     expect(page).to have_no_link('delete', wait: Capybara.default_max_wait_time * 4)
  #   end
  #   context 'admin uploads a different file' do
  #     before do
  #       find_link('Additional File').click
  #       expect(page).to have_content('[remove]')
  #       expect(page).to have_css '#final-submission-file-fields .nested-fields:last-child input[type="file"]'
  #       last_input_id = first('#final-submission-file-fields .nested-fields:last-child input[type="file"]')[:id]
  #       attach_file last_input_id, fixture('new_admin_file.pdf')
  #       click_button 'Update Metadata Only'
  #       expect(page).to have_content('Final submission information was successfully edited by an administrator')
  #       visit admin_edit_submission_path(submission)
  #     end
  #     it "it should be successful and uploaded file should be present" do
  #       expect(page).to have_content('Files')
  #       file_name = first('#final-submission-file-fields .nested-fields').find('a.file-link').text
  #       expect(file_name).to start_with('new_admin_file.pdf')
  #     end
  #   end
end
