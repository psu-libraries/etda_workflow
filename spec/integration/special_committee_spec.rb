RSpec.describe 'Special committee page', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let!(:submission) { FactoryBot.create :submission }
  let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }
  let!(:committee_member_token) { FactoryBot.create :committee_member_token, committee_member: committee_member, authentication_token: '1' }

  it 'displays content' do
    visit '/special_committee/1'
    expect(page).to have_content('New to Penn State?')
    expect(page).to have_link('Create Your Penn State Account', href: 'https://accounts.psu.edu/create/new')
    expect(page).to have_content('Already have a PSU OneID or completed your application?')
    expect(page).to have_link('Proceed to Committee Reviews')
  end

  it 'automatically proceeds to reviews if signed into webaccess' do
    allow_any_instance_of(Devise::Strategies::WebaccessAuthenticatable).to receive(:remote_user).and_return('approverflow')
    allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
    webaccess_authorize_approver
    visit '/special_committee/1'
    expect(page).to have_current_path(approver_approver_reviews_path)
  end

  it 'marries an approver and committee member record via token' do
    visit '/special_committee/1'
    allow_any_instance_of(Devise::Strategies::WebaccessAuthenticatable).to receive(:remote_user).and_return('approverflow')
    allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
    webaccess_authorize_approver
    expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 0
    find(:xpath, "//a[@href='/special_committee/1/advance_to_reviews']").click
    sleep 3
    expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 1
    expect(page).to have_current_path(approver_approver_reviews_path)
    expect(page).to have_link(submission.title)
  end
end
