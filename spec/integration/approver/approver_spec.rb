RSpec.describe 'Approver approval page', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let(:submission) { FactoryBot.create :submission, :waiting_for_final_submission_response, created_at: Time.zone.now }

  before do
    webaccess_authorize_approver
    allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
  end

  context 'approver matches committee member access_id' do
    it 'can view approval page' do
      committee_member = FactoryBot.create :committee_member, submission: submission, access_id: 'approverflow'

      visit "approver/committee_member/#{committee_member.id}"
      sleep 5
      expect(page).to have_content('approverflow')
      # This spec needs modified when view is created
    end
  end

  context 'approver does not match committee_member access_id' do
    it 'redirects to 401 error page' do
      committee_member = FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/committee_member/#{committee_member.id}"
      sleep 5
      expect(page).to have_current_path('/401')
    end
  end
end