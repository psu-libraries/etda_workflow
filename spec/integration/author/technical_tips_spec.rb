RSpec.describe "Technical Tips page", :js, type: :integration do
  require 'integration/integration_spec_helper'

  before do
    oidc_authorize_author
    visit author_submissions_path
  end

  context 'Link appears on left navigation menu for authors' do
    it 'has a link' do
      expect(page).to have_link('Technical Tips')
    end
  end

  context 'Technical tips link should work' do
    before do
      click_link 'Technical Tips'
    end

    it 'opens the technical tips page' do
      expect(page).to have_content('Technical Tips')
      expect(page).to have_content('Abc_format_review.pdf')
      expect(page).to have_content('Edge')
      expect(page).to have_link('Accessibility')
    end
  end
end
