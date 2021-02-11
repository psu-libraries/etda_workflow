RSpec.describe "Manage Contact Information", js: true do
  require 'integration/integration_spec_helper'

  before do
    oidc_authorize_author
  end

  let(:author) { current_author }

  context 'author edits personal information' do
    it 'displays a contact information page for authors' do
      FactoryBot.create :degree
      InboundLionPathRecord.new(current_data: LionPath::MockLionPathRecord::MOCK_LP_AUTHOR_RECORD)
      author = current_author
      visit author_root_path
      click_link 'Update My Contact Information'
      expect(page).to have_current_path(edit_author_author_path(author))
      expect(page).to have_content("Update Contact Information")
      expect(page).not_to have_content(author.access_id)
      expect(page).not_to have_content(author.psu_idn)
      expect(page).to have_content(author.last_name)
      expect(page).to have_content(author.first_name)
      expect(page).to have_content(author.middle_name)
      if current_partner.graduate?
        expect(page).to have_field('Phone number')
        expect(page).to have_field('Address 1')
        expect(page).to have_field('Address 2')
        expect(page).to have_field('City')
        expect(page).to have_field('State')
        select "Rhode Island", from: 'State'
        expect(page).to have_field('Zip')
        fill_in 'Zip', with: '99999'
        expect(page).to have_field('Country')
      end
      fill_in 'Alternate email address', with: 'myalternate@gmail.com'
      expect(page).to have_link('Cancel')
      click_button('Save')
      expect(page).to have_current_path(author_root_path)
      # expect(page).to have_content('Contact information updated successfully')
      visit edit_author_author_path(author)
      expect(page).to have_field('Alternate email address', with: 'myalternate@gmail.com')
      expect(page).to have_link('Accessibility')
    end
  end

  context 'author without psu_id number updates personal information' do
    it 'populates the psu_idn number when the record is saved' do
      FactoryBot.create :degree
      InboundLionPathRecord.new(current_data: LionPath::MockLionPathRecord.current_data, author: author)
      author = current_author
      author.psu_idn = ''
      expect(author.psu_idn).to be_blank
      visit edit_author_author_path(author)
      expect(page).to have_current_path(edit_author_author_path(author))
      expect(page).to have_content("Update Contact Information")
      expect(page).to have_content(author.middle_name)
      if current_partner.graduate?
        expect(page).to have_field('Phone number')
        select "Rhode Island", from: 'State'
        expect(page).to have_field('Zip')
        fill_in 'Zip', with: '99999'
        expect(page).to have_field('Country')
      end
      fill_in 'Alternate email address', with: 'mydifferentalternate@gmail.com'
      expect(page).to have_link('Cancel')
      click_button('Save')
      expect(page).to have_current_path(author_root_path)
      author.reload
      expect(author.psu_idn).not_to be_blank
      # expect(page).to have_content('Contact information updated successfully')
      visit edit_author_author_path(author)
      expect(page).to have_field('Alternate email address', with: 'mydifferentalternate@gmail.com')
      expect(page).to have_link('Accessibility')
    end
  end

  context 'when author has confidential hold' do
    it 'displays a message for confidential hold authors' do
      author.update_attribute :confidential_hold, true
      visit edit_author_author_path(author)
      expect(page).to have_content('Our records indicate there is a confidential hold')
    end
  end

  context "Author tries to edit a different author's personal information" do
    it 'displays Unauthorized message' do
      a_different_author = FactoryBot.create :author
      a_different_id = a_different_author.id
      visit "/author/authors/#{a_different_id}/edit"
      expect(page).to have_content('Unauthorized: Access Denied')
    end
  end
end
