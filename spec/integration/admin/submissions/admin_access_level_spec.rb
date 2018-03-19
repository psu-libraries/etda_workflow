RSpec.describe 'Admin submission access_level', js: true do
  require 'integration/integration_spec_helper'

  before do
    submission = FactoryBot.create :submission, :waiting_for_final_submission_response
    committee_member1 = FactoryBot.create :committee_member, submission: submission
    committee_member2 = FactoryBot.create :committee_member, submission: submission
    FactoryBot.create :format_review_file, submission: submission
    FactoryBot.create :final_submission_file, submission: submission
    submission.committee_members << committee_member1
    submission.committee_members << committee_member2
    submission.access_level = 'open_access'
    webaccess_authorize_admin
    visit admin_edit_submission_path(submission)
  end

  context 'admin users can choose the access level' do
    it 'has an open_access radio button' do
      page.find("input#submission_access_level_open_access").trigger('click')
      expect(find("#submission_access_level_open_access")).to be_checked
      expect(page).to have_content('Enter justification') unless current_partner.graduate?
    end
    it 'has a restricted_to_institution radio button' do
      page.find("input#submission_access_level_restricted_to_institution").trigger('click')
      expect(page.find("input#submission_access_level_restricted_to_institution")).to be_checked
      unless current_partner.graduate?
        expect(page).to have_content('Enter justification')
        expect(page.find('textarea#submission_restricted_notes')).to be_truthy
      end
      expect(page).to have_field('submission_invention_disclosures_attributes_0_id_number')
    end
    it 'has a restricted radio button' do
      page.find("input#submission_access_level_restricted").trigger('click')
      expect(page.find("input#submission_access_level_restricted")).to be_checked
      click_button('Update Metadata Only')
      sleep(1)
      expect(page).to have_content('Enter justification') unless current_partner.graduate?
      expect(page).to have_field('submission_invention_disclosures_attributes_0_id_number')
      inventions = page.find(:css, 'div.form-group.string.optional.submission_invention_disclosures_id_number')
      within inventions do
        fill_in 'Invention Disclosure Number (Required for Restricted Access)', with: '1234'
      end
      click_button('Update Metadata Only')
      sleep(1)
      expect(page).not_to have_content('Invention disclosure number is required for Restricted submissions.')
    end
  end
end
