RSpec.describe 'Author submission page', type: :integration, milsch: true, honors: true, js: true do
  require 'integration/integration_spec_helper'

  before do
    oidc_authorize_author
    visit author_submissions_path
  end

  let!(:author) { @current_author }

  context 'Author Submissions Page' do
    it 'displays a paragraph of thesis instructions' do
      expect(page).to have_content('You will need to input your committee, upload your format ')
    end
    it 'contains a list of submissions' do
      expect(page).to have_content('My Submissions')
      expect(page).to have_link('Start a new Submission') unless current_partner.graduate?
    end
  end

  context 'Author submission display when author has no submissions' do
    it "displays 'no submissions message'" do
      expect(page).to have_content("You don't have any submissions")
      expect(page).to have_content("in LionPATH") if current_partner.graduate?
      expect(page).to have_link('Start a new Submission') unless current_partner.graduate?
      expect(page).not_to have_link('Contact Support')
    end
  end

  context 'Author submission display when author has a submission that is released for publication but no other submissions' do
    it 'displays completed submission Button' do
      FactoryBot.create :submission, :released_for_publication, author: author
      visit author_submissions_path(author)
      expect(page).not_to have_content("You don't have any submissions yet.")
      expect(page).not_to have_content('Existing submission found. The status of your previously submitted document is listed below.')
      expect(page).to have_link('My Published Submissions')
      expect(page).to have_content('If you would like to start') unless current_partner.graduate?
    end
  end

  context 'Author submission display when author has one submission' do
    it "displays 'submission found'" do
      FactoryBot.create :submission, :collecting_committee, author: author
      visit author_submissions_path
      expect(page).to have_content('Existing submission found. The status of your previously submitted document is listed below.')
      expect(page).to have_link('Provide Committee')
      expect(page).to have_content('If you would like to start a new thesis') unless current_partner.graduate?
      new_link = find_link('Start a new Submission')
      expect(new_link['outerHTML']).to match(/You already have a/)
    end
  end

  context 'Author submission display when author has more than one submissions' do
    before do
      oidc_authorize_author
      FactoryBot.create_list :submission, 2, author: current_author
      visit author_submissions_path
    end

    it "displays 'submissions found'" do
      expect(page).to have_content('submissions found')
    end
  end
end
