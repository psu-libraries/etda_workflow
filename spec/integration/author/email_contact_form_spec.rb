RSpec.describe "Email Contact Form", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { current_author }

  # change in home page
  describe 'contact form hidden when user is not authenticated' do
    xit 'does not display the contact form link on home page' do
      visit root_path
      expect(page).not_to have_link('Contact Us')
      expect(page).to have_link('Please direct questions to Ask!')
    end
  end

  describe 'display contact form for logged in user' do
    before do
      webaccess_authorize_author
      visit author_email_contact_form_new_path
    end

    it "does not contain help link in the footer" do
      expect(page).not_to have_link('Please direct questions to Ask!')
    end
    it "displays a service header" do
      expect(page).to have_selector('h1', text: 'Contact Us')
    end
    it "displays the contact email form initialized with author information" do
      expect(page).to have_xpath("//input[@value='Send']")
      expect(page).to have_link('Cancel')
      expect(page).to have_button('Send')
      expect(page).to have_field('Your Name', with: author.full_name)
      expect(page).to have_field('Your Email', with: author.psu_email_address)
      expect(page).to have_field('Your Message')
      expect(page).to have_field('PSU ID Number', with: author.psu_id)
    end
  end

  describe 'submitting the contact form' do
    before do
      webaccess_authorize_author
      visit author_email_contact_form_new_path
    end

    it "sends an email" do
      expect(page).to have_current_path(author_email_contact_form_index_path)
      fill_in "Your Message", with: 'This is a message for ETDA'
      fill_in 'Subject', with: 'Subject is here'
      click_button "Send"
      expect(ActionMailer::Base.deliveries.first).not_to be_nil
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(page).to have_current_path(author_root_path)
      # expect(page).to have_content('Thank you for your message')
    end
    it 'displays an error when message field is blank' do
      fill_in "Your Message", with: ''
      click_button "Send"
      expect(page).to have_current_path(author_email_contact_form_index_path)
      expect(ActionMailer::Base.deliveries.first).to be_nil
      expect(ActionMailer::Base.deliveries.count).to be_zero
      expect(page).to have_content("can't be blank")
    end
  end
end
