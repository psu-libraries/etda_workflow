RSpec.describe 'Approver reviews page', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, created_at: Time.zone.now }
  let(:submission1) { FactoryBot.create :submission, :waiting_for_final_submission_response, created_at: Time.zone.now }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }
  let(:committee_role) { FactoryBot.create :committee_role, name: "Dissertation Advisor" }
  let(:approval_configuration) { FactoryBot.create :approval_configuration }
  let!(:committee_member) { FactoryBot.create :committee_member, committee_role: committee_role, submission: submission, access_id: 'approverflow' }

  before do
    allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
    submission.final_submission_files << final_submission_file
    submission.degree.degree_type.approval_configuration = approval_configuration
    webaccess_authorize_approver
  end

  it "updates approver's committee member records and lists them" do
    expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 0
    visit '/approver/reviews'
    expect(page).to have_link(submission.title)
    expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 1
  end

  it 'can visit a single committee member review' do
    visit '/approver/reviews'
    click_on submission.title
    expect(page).to have_current_path(approver_path(committee_member))
  end
end
