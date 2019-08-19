RSpec.describe "when an admin views the final submission is pending bucket", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let(:submission1) { FactoryBot.create :submission, :waiting_for_committee_review, author: author }

  before do
    FactoryBot.create :submission, :waiting_for_head_of_program_review, author: author
    webaccess_authorize_admin
    visit admin_submissions_index_path(submission1.degree.degree_type, :final_submission_pending)
    sleep 3
  end

  it 'has submission status in header and indicates status in body' do
    expect(page).to have_content('Submission Status')
    expect(page).to have_content('Waiting for committee review')
    expect(page).to have_content('Waiting for head of program review')
  end
end
