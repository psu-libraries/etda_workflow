RSpec.describe "Placing a final submission on hold as an admin", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let!(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, author: author }
  let(:committee) { create_committee(submission) }
  let!(:hold_submission) { FactoryBot.create(:submission, :waiting_in_final_submission_hold, author: author) }

  before do
    webaccess_authorize_admin
  end

  context 'when visiting the queues dashboard' do
    it 'can select the final submission on hold queue' do
      visit admin_submissions_dashboard_path(DegreeType.default)
      find('h2', text: 'Final Submission is On Hold').click
      expect(page).to have_content('Final Submission is On Hold')
      expect(page).to have_content('Search:')
    end
  end

  context 'when submission is waiting in final submission to be released' do
    it 'moves submission to waiting in final submission on hold' do
      visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
      click_link submission.title
      click_button 'Place this Submission On Hold'
      expect(Submission.find(submission.id).placed_on_hold_at).to be_truthy
      expect(Submission.find(submission.id).removed_hold_at).to be_falsey
    end
  end

  context 'when submission is waiting in final submission in on hold' do
    it 'moves submission to waiting in final submission to be released' do
      visit admin_submissions_index_path(DegreeType.default, 'final_submission_on_hold')
      click_link hold_submission.title
      click_button 'Remove from Hold'
      expect(Submission.find(hold_submission.id).removed_hold_at).to be_truthy
      expect(Submission.find(hold_submission.id).placed_on_hold_at).to be_falsey
    end
  end
end
