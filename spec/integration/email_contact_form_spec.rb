RSpec.describe "Email Contact Form", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { current_author }
  let(:approver) { current_approver }

  # change in main page
  describe 'contact form hidden when user is not authenticated' do
    xit 'does not display the contact form link on main page' do
      visit root_path
      expect(page).not_to have_link('Contact Us')
      expect(page).to have_link('Please direct questions to Ask!')
    end
  end

  describe 'display contact form for logged in user' do
    before do
      webaccess_authorize_author
      visit '/author'
      visit email_contact_form_new_path
    end

    it "does not contain help link in the footer" do
      expect(page).not_to have_link('Please direct questions to Ask!')
    end
    it "displays a service header" do
      expect(page).to have_selector('h1', text: 'Contact Us')
    end
    it "has issue type tooltip" do
      tooltip = find('span[data-toggle="tooltip"]')
      tooltip.hover
      expect(page).to have_content('Your email will be directed to IT support')
      expect(page).to have_css('div.tooltip')
    end
    it "displays the contact email form initialized with author information" do
      expect(page).to have_xpath("//input[@value='Send']")
      expect(page).to have_link('Cancel')
      expect(page).to have_button('Send')
      expect(page).to have_field('Your Name', with: author.full_name)
      expect(page).to have_field('Your Email', with: author.psu_email_address)
      expect(page).to have_field('Issue type')
      expect(page).to have_field('Your Message')
      expect(page).to have_field('PSU ID Number', with: author.psu_id)
    end
  end

  describe 'submitting the contact form' do
    before do
      webaccess_authorize_author
      visit '/author'
      visit email_contact_form_new_path
    end

    it "sends an email" do
      expect(page).to have_current_path(email_contact_form_index_path)
      fill_in "Your Message", with: 'This is a message for ETDA'
      fill_in 'Subject', with: 'Subject is here'
      click_button "Send"
      expect(ActionMailer::Base.deliveries.first).not_to be_nil
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(page).to have_current_path(main_page_path)
      # expect(page).to have_content('Thank you for your message')
    end

    it 'displays an error when message field is blank' do
      fill_in "Your Message", with: ''
      click_button "Send"
      expect(page).to have_current_path(email_contact_form_index_path)
      expect(ActionMailer::Base.deliveries.first).to be_nil
      expect(ActionMailer::Base.deliveries.count).to be_zero
      expect(page).to have_content("can't be blank")
    end
  end

  describe 'clicking cancel' do
    context 'when author session' do
      it "returns to author root" do
        webaccess_authorize_author
        visit '/author'
        visit email_contact_form_new_path
        click_link "Cancel"
        expect(page).to have_current_path(author_root)
      end
    end

    context 'when approver session' do
      it "returns to approver page" do
        allow_any_instance_of(ApplicationController).to receive(:current_remote_user).and_return('approverflow')
        webaccess_authorize_approver
        visit '/approver'
        visit email_contact_form_new_path
        expect(page).not_to have_field('PSU ID Number')
        click_link "Cancel"
        expect(page).to have_current_path(approver_root_path)
      end
    end
  end
end
