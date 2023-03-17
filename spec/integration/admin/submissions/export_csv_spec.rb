RSpec.describe "Exporting a list of approved submissions as an admin", type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let!(:submission) { FactoryBot.create :submission, author: }
  let(:committee) { FactoryBot.create_committee(submission) }

  context "when an admin exports a CSV file" do
    let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release }
    let(:admin) { FactoryBot.create :admin }

    before do
      oidc_authorize_admin
      visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
      sleep 1
    end

    it 'has a button to export submissions to a CSV file', retry: 5 do
      expect(page).to have_content('Final Submission to be Released')
      find_button('Select Visible')
      click_button 'Select Visible'
      expect(page).to have_button('Export CSV')
    end
  end
end
