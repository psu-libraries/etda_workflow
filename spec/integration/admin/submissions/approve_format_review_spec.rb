RSpec.describe "when an admin approves a format review", type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let!(:author) { FactoryBot.create :author }
  let!(:degree_type) { DegreeType.find_by(slug: 'master_thesis') }
  let!(:degree) { FactoryBot.create :degree, degree_type: }
  let!(:submission) { FactoryBot.create :submission, :waiting_for_format_review_response, author:, degree: }
  let!(:file) { FactoryBot.create :format_review_file, submission: }

  before do
    oidc_authorize_admin
  end

  context "when an admin accepts the format review files" do
    it "changes status to 'collecting final submission files'" do
      expect(submission.format_review_approved_at).to be_nil
      visit admin_edit_submission_path(submission)
      fill_in 'Format Review Notes to Student', with: 'Note on format review'
      click_button 'Format Review Completed'
      # expect(page).to have_content('successfully')
      submission.reload
      expect(submission.status).to eq 'collecting final submission files'
      submission.reload
      expect(submission.format_review_approved_at).not_to be_nil
    end
  end

  context "when an admin rejects the format review files" do
    it "changes status to 'collecting format review files rejected'" do
      expect(submission.format_review_rejected_at).to be_nil
      visit admin_edit_submission_path(submission)
      fill_in 'Format Review Notes to Student', with: 'Note on need for revisions'
      click_button 'Reject & request revisions'
      # expect(page).to have_content('successfully')
      submission.reload
      expect(submission.status).to eq 'collecting format review files rejected'
      submission.reload
      expect(submission.format_review_rejected_at).not_to be_nil
    end
  end
end
