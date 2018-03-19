RSpec.describe 'Author submission page', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  before do
    webaccess_authorize_author
    visit author_submissions_path
  end

  let!(:author) { current_author }

  context 'Author Submissions Page' do
    it 'displays a paragraph of thesis instructions' do
      expect(page).to have_content('The thesis submission process requires the submission ')
    end
    it 'contains a list of submissions' do
      expect(page).to have_content('My Submissions')
      expect(page).to have_link('Start a new Submission')
    end
  end

  context 'Author submission display when author has no submissions' do
    it "displays 'no submissions message'" do
      expect(page).to have_content("You don't have any submissions")
      expect(page).to have_link('Start a new Submission')
      expect(page).not_to have_link('Contact Support')
    end
  end
  context 'Author submission display when author has one submission' do
    it "displays 'submission found'" do
      FactoryBot.create :submission, :collecting_committee, author: author
      visit author_submissions_path
      expect(page).to have_content("Existing thesis submission found")
      expect(page).to have_link('Provide Committee')
    end
  end
  context 'Author submission display when author has more than one submissions' do
    before do
      webaccess_authorize_author
      2.times do
        FactoryBot.create :submission, author: current_author
      end
      visit author_submissions_path
    end
    it "displays 'submissions found'" do
      expect(page).to have_content('submissions found')
    end
  end
end
