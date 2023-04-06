RSpec.describe "Email Contact Form", type: :integration, js: true do
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
      oidc_authorize_author
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
      expect(page).to have_content(/IT\/administrative support staff | directed to The Libraries engineering team/)
      expect(page).to have_css('div.tooltip')
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
      oidc_authorize_author
      visit '/author'
      visit email_contact_form_new_path
    end

    context 'when general issue is selected' do
      it "sends an email to partner" do
        expect(page).to have_current_path(email_contact_form_index_path)
        fill_in "Your Message", with: 'This is a message for ETDA'
        fill_in 'Subject', with: 'Subject is here'
        click_button "Send"
        expect(ActionMailer::Base.deliveries.first).not_to be_nil
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.to).to eq([current_partner.email_address.to_s])
        expect(page).to have_current_path(main_page_path)
        # expect(page).to have_content('Thank you for your message')
      end
    end

    context 'when failures is selected' do
      it "sends an email to dev team" do
        expect(page).to have_current_path(email_contact_form_index_path)
        fill_in "Your Message", with: 'This is a message for ETDA'
        fill_in 'Subject', with: 'Subject is here'
        select 'Site Failures/500 Errors', from: 'email_contact_form_issue_type'
        click_button "Send"
        expect(ActionMailer::Base.deliveries.first).not_to be_nil
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.to).to eq([I18n.t('ul_etda_support_email_address')])
        expect(page).to have_current_path(main_page_path)
        # expect(page).to have_content('Thank you for your message')
      end
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
        oidc_authorize_author
        visit '/author'
        visit email_contact_form_new_path
        click_link "Cancel"
        expect(page).to have_current_path(author_root_path)
      end
    end

    context 'when approver session' do
      it "returns to approver page" do
        allow_any_instance_of(ApplicationController).to receive(:current_remote_user).and_return('approverflow')
        oidc_authorize_approver
        visit '/approver'
        visit email_contact_form_new_path
        expect(page).not_to have_field('PSU ID Number')
        click_link "Cancel"
        expect(page).to have_current_path(approver_root_path)
      end
    end
  end
end
