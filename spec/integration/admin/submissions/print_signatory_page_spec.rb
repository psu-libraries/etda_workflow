RSpec.describe "Printing a graduate signatory page as an admin", js: true do
  require 'integration/integration_spec_helper'

  let(:submission_author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create(:submission, :waiting_for_format_review_response) }
  let(:admin) { FactoryBot.create :admin }

  before do
    create_committee(submission)
    webaccess_authorize_admin
    visit admin_submissions_index_path(submission.degree_type.slug, 'format_review_submitted')
  end

  if current_partner.graduate?

    it "indicates the submission has not been printed when partner is graduate" do
      expect(page).to have_content('No')
    end

    it "displays the submission print page when partner is graduate" do
      click_link "Print Page"
      sleep(5)
      # page.find('div#print-button')
      expect(page).to have_content('INTENT')
      expect(page).to have_content(submission.author.last_name)
      expect(page).to have_content(submission.degree.name)
      expect(page).to have_content(submission.semester)
      expect(page).to have_content(submission.year)
      expect(page).to have_content("NOTES")
    end
  else
    it 'does not contain a print button for other partners' do
      expect(page).not_to have_link('Print Page')
      expect(page).not_to have_content('Printed')
    end
  end
end
