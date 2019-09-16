RSpec.describe "when an admin approves a final submission", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create :submission, :waiting_for_final_submission_response, author: author }

  before do
    webaccess_authorize_admin
    visit admin_edit_submission_path(submission)
  end

  it 'displays pop-up when admin clicks "Approve Final Submission"' do
    skip 'Non honors' if current_partner.honors?

    accept_confirm do
      click_button 'Approve Final Submission'
    end
    expect(page).to have_current_path(admin_submissions_index_path(submission.degree.degree_type, :final_submission_submitted))
  end
end
