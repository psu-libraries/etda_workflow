RSpec.describe "Step 6: Waiting for Head of Program Review'", js: true do
  require 'integration/integration_spec_helper'

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
    let(:head_role) { CommitteeRole.find_by(name: 'Program Head/Chair', is_program_head: true, degree_type: submission.degree.degree_type) }

    let(:head_of_program) { FactoryBot.create :committee_member, :required, submission: submission, committee_role: head_role, access_id: 'approverflow' } if current_partner.graduate?

    context 'when author tries visiting various pages' do
      before do
        oidc_authorize_author
      end

      context "visiting the 'Update Program Information' page" do
        it "raises a forbidden access error" do
          visit edit_author_submission_path(submission)
          expect(page).to have_current_path(author_root_path)
        end
      end

      context "visiting the 'Provide Committee' page" do
        it "raises a forbidden access error" do
          visit new_author_submission_committee_members_path(submission)
          expect(page).to have_current_path(author_root_path)
        end
      end

      context "visiting the 'Update Committee' page" do
        it "raises a forbidden access error" do
          visit edit_author_submission_committee_members_path(submission)
          expect(page).to have_current_path(author_root_path)
        end
      end

      context "visiting the 'Upload Format Review Files' page" do
        it "raises a forbidden access error" do
          visit author_submission_edit_format_review_path(submission)
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
        allow_any_instance_of(ApplicationController).to receive(:current_remote_user).and_return('approverflow')
        oidc_authorize_approver
        head_of_program.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id if current_partner.graduate?
      end

      context "when 'waiting for head of program review'" do
        it "proceeds to 'waiting for final submission response' if approved" do
          FactoryBot.create :admin
          visit approver_path(head_of_program)
          within("form#edit_committee_member_#{head_of_program.id}") do
            find(:css, "#committee_member_status_approved").set true
          end
          click_button 'Submit Review'
          expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
          expect(WorkflowMailer.deliveries.count).to eq 1
        end

        it "proceeds to 'waiting for committee review rejected' if rejected" do
          FactoryBot.create :admin
          visit approver_path(head_of_program)
          within("form#edit_committee_member_#{head_of_program.id}") do
            find('#committee_member_status_rejected').click
          end
          find('#committee_member_notes').send_keys('Notes')
          click_button 'Submit Review'
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
          expect(WorkflowMailer.deliveries.count).to eq 2
        end

        it "proceeds to 'waiting for committee review rejected' if rejected but doesn't send emails" do
          FactoryBot.create :admin
          approval_configuration.update email_admins: false, email_authors: false
          visit approver_path(head_of_program)
          within("form#edit_committee_member_#{head_of_program.id}") do
            find(:css, "#committee_member_status_rejected").set true
          end
          find('#committee_member_notes').send_keys('Notes')
          click_button 'Submit Review'
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
          expect(WorkflowMailer.deliveries.count).to eq 0
        end
      end
    end
  end
end
