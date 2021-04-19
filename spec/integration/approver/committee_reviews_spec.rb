RSpec.describe 'Approver approval page', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, created_at: Time.zone.now }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }
  let(:approval_configuration) { FactoryBot.create :approval_configuration }
  let(:committee_role) { FactoryBot.create :committee_role }

  before do
    submission.final_submission_files << final_submission_file
    submission.degree.degree_type.approval_configuration = approval_configuration
    oidc_authorize_approver
  end

  context 'approver matches committee member access_id' do
    before do
      committee_member.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
      visit "approver/committee_member/#{committee_member.id}"
    end

    let(:committee_member) { FactoryBot.create :committee_member, submission: submission, access_id: 'approverflow' }

    it 'can see other committee members reviews' do
      expect(page).to have_content('Committee Reviews')
      expect(page).to have_content('Name')
      expect(page).to have_content('Federal Funding Used:')
      expect(page).to have_content('Status')
      expect(page).to have_content('Notes')
    end
  end
end
