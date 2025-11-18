RSpec.describe "Author Navigation", :js, type: :integration do
  require 'integration/integration_spec_helper'

  before do
    oidc_authorize_author
    visit '/author'
  end

  let(:author) { current_author }

  it 'has top navigation' do
    expect(page).to have_link('Home')
    expect(page).to have_link('About')
    expect(page).to have_link('Contact Us')
    expect(page).to have_link('Explore')
    expect(page).to have_link('Log Out')
  end

  it 'has an about page', :honors do
    click_link 'About'
    expect(page).to have_link('Thesis and Dissertation Guide') if current_partner.graduate?
    expect(page).to have_link('Thesis Guide') unless current_partner.graduate?
    expect(page).to have_content(current_partner.slug.to_s)
    expect(page).to have_content('Important Things')
    expect(page).to have_content('Expand Creative Possibilities')
    expect(page).to have_content('Format Standards and Process')
  end

  it 'has a main page' do
    click_link 'Home'
    expect(page).to have_link('ETDA Explore')
    expect(page).to have_link('Log Out')
    expect(page).to have_link('Create/Edit Submission')
    expect(page).not_to have_link('Admin')
    within('nav#account-navigation') do
      expect(page).to have_link('Home')
      expect(page).to have_link('About')
      expect(page).to have_link('Contact Us')
      expect(page).not_to have_link('Explore')
    end
  end
end
