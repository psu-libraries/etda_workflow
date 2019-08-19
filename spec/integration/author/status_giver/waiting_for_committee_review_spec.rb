RSpec.describe "Step 7: Waiting for Committee Review'", js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'waiting for committee review'" do
    before do
      submission.final_submission_files << final_submission_file
      submission.degree.degree_type.approval_configuration = approval_configuration
    end

    let(:author) { current_author }
    let(:approver) { current_approver }
    let(:degree) { FactoryBot.create :degree }
    let(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, author: author, degree: degree }
    let(:committee_member) { FactoryBot.create :committee_member, submission: submission, access_id: 'approverflow' }
    let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }
    let(:approval_configuration) { FactoryBot.create :approval_configuration, configuration_threshold: 0, email_authors: true, email_admins: true }
    let(:head_role) { CommitteeRole.find_by(name: 'Program Head/Chair', degree_type: submission.degree.degree_type) }

    context 'when author tries visiting various pages' do
      before do
        webaccess_authorize_author
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

      context "visiting the 'Review Waiting for Committee' page" do
        it "loads the page" do
          visit author_submission_committee_review_path(submission)
          expect(page).to have_current_path(author_submission_committee_review_path(submission))
        end
      end

      context "visiting the 'Review Final Submission Files' page" do
        it "loads the page" do
          visit author_submission_final_submission_path(submission)
          expect(page).to have_current_path(author_submission_final_submission_path(submission))
        end
      end

      context "when status is 'waiting for committee review rejected'" do
        before do
          submission.update_attribute :status, 'waiting for committee review rejected'
          submission.degree.degree_type.approval_configuration.update_attribute :head_of_program_is_approving, false
          submission.keywords << (FactoryBot.create :keyword)
        end

        it 'can edit final submission' do
          visit author_submission_edit_final_submission_path(submission)
          expect(page).to have_current_path(author_submission_edit_final_submission_path(submission))
          fill_in "Title", with: "A Brand New Title"
          select "Fall", from: "Semester Intending to Graduate"
          select 1.year.from_now.year, from: "Graduation Year"
          fill_in 'Abstract', with: 'Abstract'
          find('#submission_access_level_open_access').click if current_partner.graduate?
          click_link "Additional File"
          within('#final-submission-file-fields') do
            all('input[type="file"]').first.set(fixture('final_submission_file_01.pdf'))
          end
          find('#submission_has_agreed_to_terms').click
          click_button 'Submit final files for review'
          sleep 1
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
        end
      end
    end

    context "when committee reviews" do
      before do
        allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
        webaccess_authorize_approver
      end

      it "moves forward in process if accepted when head of program is approving" do
        skip 'Graduate Only' unless current_partner.graduate?

        submission.degree.degree_type.approval_configuration.head_of_program_is_approving = true
        submission.committee_members << (FactoryBot.create :committee_member, committee_role_id: head_role.id)
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find(:css, "#committee_member_status_approved").set true
        end
        click_button 'Submit Review'
        sleep 3
        expect(Submission.find(submission.id).status).to eq 'waiting for head of program review'
      end

      it "proceeds to 'waiting for publication release' when head of program is approving if head already accepted" do
        skip 'Graduate Only' unless current_partner.graduate?

        FactoryBot.create :committee_member, :required, submission: submission, committee_role: head_role, status: 'approved', access_id: 'approverflow'
        submission.degree.degree_type.approval_configuration.head_of_program_is_approving = true
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find(:css, "#committee_member_status_approved").set true
        end
        click_button 'Submit Review'
        sleep 3
        expect(Submission.find(submission.id).status).to eq 'waiting for publication release'
      end

      it "moves forward in process if accepted when head of program is not approving" do
        submission.degree.degree_type.approval_configuration.update_attribute :head_of_program_is_approving, false
        FactoryBot.create :admin
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find(:css, "#committee_member_status_approved").set true
        end
        click_button 'Submit Review'
        sleep 3
        expect(Submission.find(submission.id).status).to eq 'waiting for publication release'
        expect(WorkflowMailer.deliveries.count).to eq 1 unless current_partner.honors?
        expect(WorkflowMailer.deliveries.count).to eq 2 if current_partner.honors?
      end

      it "moves forward in process if accepted when head of program is not approving but does not send email" do
        submission.degree.degree_type.approval_configuration.update_attributes head_of_program_is_approving: false, email_admins: false, email_authors: false
        FactoryBot.create :admin
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find('#committee_member_status_approved').click
        end
        click_button 'Submit Review'
        sleep 3
        expect(Submission.find(submission.id).status).to eq 'waiting for publication release'
        expect(WorkflowMailer.deliveries.count).to eq 0 unless current_partner.honors?
        expect(WorkflowMailer.deliveries.count).to eq 1 if current_partner.honors?
      end

      it "proceeds to 'waiting for committee review rejected' if rejected" do
        FactoryBot.create :admin
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find(:css, "#committee_member_status_rejected").set true
        end
        click_button 'Submit Review'
        sleep 3
        expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
        expect(WorkflowMailer.deliveries.count).to eq 2
      end
    end
  end

  describe "When status is 'waiting for head of program review'" do
    before do
      submission.final_submission_files << final_submission_file
      submission.degree.degree_type.approval_configuration = approval_configuration
    end

    let(:author) { current_author }
    let(:approver) { current_approver }
    let(:degree) { FactoryBot.create :degree }
    let(:submission) { FactoryBot.create :submission, :waiting_for_head_of_program_review, author: author, degree: degree }
    let(:committee_member) { FactoryBot.create :committee_member, submission: submission, access_id: 'approverflow' }
    let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }
    let(:approval_configuration) { FactoryBot.create :approval_configuration, configuration_threshold: 0, email_authors: true, email_admins: true }
    let(:head_role) { CommitteeRole.find_by(name: 'Program Head/Chair', degree_type: submission.degree.degree_type) }
    let(:head_of_program) { FactoryBot.create :committee_member, :required, submission: submission, committee_role: head_role, access_id: 'approverflow' }

    context 'when author tries visiting various pages' do
      before do
        webaccess_authorize_author
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

      context "visiting the 'Review Waiting for Committee' page" do
        it "loads the page" do
          visit author_submission_committee_review_path(submission)
          expect(page).to have_current_path(author_submission_committee_review_path(submission))
        end
      end

      context "visiting the 'Review Final Submission Files' page" do
        it "loads the page" do
          visit author_submission_final_submission_path(submission)
          expect(page).to have_current_path(author_submission_final_submission_path(submission))
        end
      end
    end

    context "when committee reviews" do
      before do
        allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
        webaccess_authorize_approver
      end

      context "when 'waiting for head of program review'" do
        it "proceeds to 'waiting for publication release' if approved" do
          skip 'Graduate only' unless current_partner.graduate?

          FactoryBot.create :admin
          visit approver_path(head_of_program)
          within("form#edit_committee_member_#{head_of_program.id}") do
            find(:css, "#committee_member_status_approved").set true
          end
          click_button 'Submit Review'
          sleep 3
          expect(Submission.find(submission.id).status).to eq 'waiting for publication release'
          expect(WorkflowMailer.deliveries.count).to eq 1
        end

        it "proceeds to 'waiting for committee review rejected' if rejected" do
          skip 'Graduate only' unless current_partner.graduate?

          FactoryBot.create :admin
          visit approver_path(head_of_program)
          within("form#edit_committee_member_#{head_of_program.id}") do
            find('#committee_member_status_rejected').click
          end
          click_button 'Submit Review'
          sleep 3
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
          expect(WorkflowMailer.deliveries.count).to eq 2
        end

        it "proceeds to 'waiting for committee review rejected' if rejected but doesn't send emails" do
          skip 'Graduate only' unless current_partner.graduate?

          FactoryBot.create :admin
          approval_configuration.update_attributes email_admins: false, email_authors: false
          visit approver_path(head_of_program)
          within("form#edit_committee_member_#{head_of_program.id}") do
            find(:css, "#committee_member_status_rejected").set true
          end
          click_button 'Submit Review'
          sleep 3
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
          expect(WorkflowMailer.deliveries.count).to eq 0
        end
      end
    end
  end
end
