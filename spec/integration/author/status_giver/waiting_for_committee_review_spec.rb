RSpec.describe "When Waiting for Committee Review", :js, type: :integration do
  require 'integration/integration_spec_helper'

  describe "When status is 'waiting for committee review'" do
    before do
      submission.final_submission_files << final_submission_file
      submission.degree.degree_type.approval_configuration = approval_configuration
    end

    let(:author) { current_author }
    let(:approver) { current_approver }
    let(:degree) { FactoryBot.create :degree }
    let(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, author:, degree: }
    let(:committee_member) { FactoryBot.create :committee_member, submission:, access_id: 'approverflow' }
    let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: }
    let(:approval_configuration) do
      FactoryBot.create :approval_configuration, configuration_threshold: 0, email_authors: true, email_admins: true
    end
    let(:head_role) do
      CommitteeRole.find_by(name: 'Program Head/Chair',
                            is_program_head: true,
                            degree_type: submission.degree.degree_type)
    end

    context 'when author tries visiting various pages' do
      before do
        oidc_authorize_author
      end

      context "when status is 'waiting for committee review rejected'" do
        before do
          submission.update_attribute :status, 'waiting for committee review rejected'
          submission.degree.degree_type.approval_configuration.update_attribute :head_of_program_is_approving, false
          submission.keywords << (FactoryBot.create :keyword)
        end

        it 'can edit final submission', :honors do
          visit author_submission_edit_final_submission_path(submission)
          expect(page).to have_current_path(author_submission_edit_final_submission_path(submission))
          fill_in "Title", with: "A Brand New Title"
          select "Fall", from: "Semester Intending to Graduate"
          select 1.year.from_now.year, from: "Graduation Year"
          fill_in 'Abstract', with: 'Abstract'
          if current_partner.graduate?
            find("#submission_federal_funding_details_attributes_training_support_funding_false").click
            find("#submission_federal_funding_details_attributes_other_funding_false").click
          else
            find('#submission_federal_funding_false').click
          end
          find('#submission_access_level_open_access').click if current_partner.graduate?
          click_link "Additional File"
          within('#final-submission-file-fields') do
            all('input[type="file"]').first.set(file_fixture('final_submission_file_01.pdf'))
          end
          click_button 'Submit final files for review'
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
        end

        it 'displays error message if trying to make invalid changes' do
          visit author_submission_edit_final_submission_path(submission)
          find("#submission_federal_funding_details_attributes_training_support_funding_true").click
          find("#submission_federal_funding_details_attributes_training_support_acknowledged_false").click
          click_button 'Submit final files for review'
          within('.alert-danger') do
            expect(page).to have_content 'It is a federal requirement that all funding used to support research be acknowledged.'
          end
          expect(submission.status).to eq 'waiting for committee review rejected'
        end
      end
    end

    context "when committee reviews" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_remote_user).and_return('approverflow')
        oidc_authorize_approver
        committee_member.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
      end

      it "moves forward in process if accepted when head of program is approving" do
        submission.degree.degree_type.approval_configuration.head_of_program_is_approving = true
        submission.committee_members << (FactoryBot.create :committee_member, committee_role_id: head_role.id, access_id: 'abc123')
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find(:css, "#committee_member_status_approved").set true
        end
        click_button 'Submit Review'
        expect(Submission.find(submission.id).status).to eq 'waiting for head of program review'
      end

      it "proceeds to 'waiting for final submission response' when head of program is approving if head already accepted", js: false do
        FactoryBot.create(:committee_member, :required, submission:, committee_role: head_role, status: 'approved', access_id: 'approverflow')
        submission.degree.degree_type.approval_configuration.head_of_program_is_approving = true
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find(:css, "#committee_member_status_approved").set true
        end
        click_button 'Submit Review'
        expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
      end

      it "moves forward in process if accepted when head of program is not approving" do
        submission.degree.degree_type.approval_configuration.update_attribute :head_of_program_is_approving, false
        FactoryBot.create :admin
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find(:css, "#committee_member_status_approved").set true
        end
        click_button 'Submit Review'
        expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
        expect(WorkflowMailer.deliveries.count).to eq 1
      end

      it "moves forward in process if accepted when head of program is not approving but does not send email" do
        submission.degree.degree_type.approval_configuration.update head_of_program_is_approving: false, email_admins: false, email_authors: false
        FactoryBot.create :admin
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find('#committee_member_status_approved').click
        end
        click_button 'Submit Review'
        expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
        expect(WorkflowMailer.deliveries.count).to eq 0
      end

      it "proceeds to 'waiting for committee review rejected' if rejected" do
        FactoryBot.create :admin
        degree.degree_type.approval_configuration.email_admins = true
        degree.degree_type.approval_configuration.email_authors = true
        visit approver_path(committee_member)
        within("form#edit_committee_member_#{committee_member.id}") do
          find(:css, "#committee_member_status_rejected").set true
        end
        find('#committee_member_notes').send_keys('Notes')
        click_button 'Submit Review'
        expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
        expect(WorkflowMailer.deliveries.count).to eq 3
      end
    end
  end
end
