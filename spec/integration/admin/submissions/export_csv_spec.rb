RSpec.describe "Exporting a list of approved submissions as an admin", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let!(:submission) { FactoryBot.create :submission, author: author }
  let(:committee) { FactoryBot.create_committee(submission) }

  context "when an admin exports a CSV file" do
    let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release }
    let(:admin) { FactoryBot.create :admin }

    before do
      webaccess_authorize_admin
      visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
    end

    it 'has a button to export submissions to a CSV file' do
      expect(page).to have_content('Final Submission to be Released', wait: 5)
      find_button('Select Visible', wait: 8)
      click_button 'Select Visible'
      expect(page).to have_button('Export CSV')
    end
  end
end
