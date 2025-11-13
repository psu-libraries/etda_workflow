RSpec.describe "when admin responds to final submission", :js, type: :integration do
  require 'integration/integration_spec_helper'

  let!(:author) { FactoryBot.create :author }
  let!(:degree) { FactoryBot.create :degree }
  let!(:submission) do
    FactoryBot.create :submission, :waiting_for_final_submission_response, author:, degree:
  end

  let!(:committee_members) do
    [(FactoryBot.create :committee_member),
     (FactoryBot.create :committee_member)]
  end

  let!(:approval_configuration) do
    FactoryBot.create :approval_configuration, degree_type: degree.degree_type,
                                               configuration_threshold: 0, email_authors: true,
                                               use_percentage: false, email_admins: true
  end

  before do
    oidc_authorize_admin
  end

  describe "when an admin accepts the final submission files" do
    it "updates status to 'waiting for committee review' and emails committee members", :honors do
      submission.committee_members << committee_members
      submission.save!
      submission.reload
      select_year = Date.current.year - 2
      select_month = 'Mar'
      select_day = '1'
      submission.final_submission_approved_at = nil
      create_committee(submission)
      FactoryBot.create(:format_review_file, submission:)
      FactoryBot.create(:final_submission_file, submission:)
      visit admin_edit_submission_path(submission)
      sleep 1
      fill_in 'Final Submission Notes to Student', with: 'Note on paper is approved'
      if current_partner.graduate?
        select select_year, from: 'submission[defended_at(1i)]'
        select select_month, from: 'submission[defended_at(2i)]'
        select select_day, from: 'submission[defended_at(3i)]'
      end
      page.accept_confirm do
        click_button 'Approve Final Submission'
      end
      expect(page).to have_content("The submission's final submission information was successfully approved.")
      submission.reload
      expect(submission.status).to eq 'waiting for publication release'
      expect(submission.final_submission_approved_at).not_to be_nil
      expect(formatted_date(submission.defended_at)).to eq(formatted_date(Date.parse("#{select_year}-#{select_month}-#{select_day}"))) if current_partner.graduate?
      expect(WorkflowMailer.deliveries.count).to eq(1)
    end
  end

  describe "when an admin rejects the final submission files" do
    it "updates status to 'collecting final submission files rejected'" do
      submission.status = 'collecting final submission files'
      submission.final_submission_rejected_at = nil
      submission.final_submission_approved_at = nil
      FactoryBot.create(:format_review_file, submission:)
      FactoryBot.create(:final_submission_file, submission:)
      visit admin_edit_submission_path(submission)
      fill_in 'Final Submission Notes to Student', with: 'Note on need for revisions'
      page.accept_confirm do
        click_button 'Reject & request revisions'
      end
      expect(page).to have_content('final submission information was successfully rejected and returned to the author for revision')
      submission.reload
      expect(submission.status).to eq 'collecting final submission files rejected'
      submission.reload
      expect(submission.final_submission_rejected_at).not_to be_nil
    end
  end

  describe "when an admin clicks 'Send to committee'", :honors do
    it "updates status to 'waiting for advisor review' for graduate and 'waiting for committee review' for other partners" do
      create_committee submission
      submission.reload
      visit admin_edit_submission_path(submission)
      page.accept_confirm do
        click_button 'Send to committee'
      end
      expect(page).to have_content('successfully returned to the committee review stage and the committee was notified to visit the site for review.')
      submission.reload
      expect(submission.status).to eq 'waiting for advisor review' if current_partner.graduate?
      expect(submission.status).to eq 'waiting for committee review' unless current_partner.graduate?
      expect(WorkflowMailer.deliveries.last.subject).to eq "Committee Review Initiated"
    end
  end

  describe "when an admin clicks 'Send to program head'" do
    context 'when head of program is approving' do
      it "updates status to 'waiting for head of program review'" do
        submission.committee_members << FactoryBot.create(:committee_member,
                                                          committee_role: CommitteeRole.find_by(degree_type: submission.degree_type,
                                                                                                is_program_head: true))
        visit admin_edit_submission_path(submission)
        page.accept_confirm do
          click_button 'Send to program head'
        end
        expect(page).to have_content('program head review stage and the program head')
        submission.reload
        expect(submission.status).to eq 'waiting for head of program review'
      end
    end

    context 'when head of program is not approving' do
      before do
        submission.degree_type.approval_configuration.update head_of_program_is_approving: false
      end

      it "does not show button" do
        visit admin_edit_submission_path(submission)
        expect(page).not_to have_button 'Send to program head'
      end
    end
  end
end
