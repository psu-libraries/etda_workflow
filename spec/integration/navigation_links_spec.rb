RSpec.describe "Navigation Links", js: true do
require 'integration/integration_spec_helper'

before do
  webaccess_authorize_author
  visit '/'
end

let(:author) { current_author }

it 'has top navigation' do
  sleep 3
  expect(page).to have_link('Home')
  expect(page).to have_link('Explore')
  expect(page).to have_link('About')
  expect(page).to have_link('Contact Us')
  expect(page).to have_link('Log Out')
end

it 'has an about page' do
  click_link 'About'
  expect(page).to have_content(I18n.t("#{current_partner.id}.partner.description.title"))
  page_info = t("#{current_partner.id}.partner.description.text", thesis_guide_link: I18n.t("#{current_partner.id}.partner.thesis_guide")).html_safe
  expect(page).to have_content(page_info[15..30])
end
end
