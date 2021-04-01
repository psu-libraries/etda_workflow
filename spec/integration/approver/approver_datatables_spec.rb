RSpec.describe 'Approver datatables', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, created_at: Time.zone.now, final_submission_files_uploaded_at: DateTime.now, final_submission_approved_at: DateTime.now }
  let(:submission1) { FactoryBot.create :submission, :collecting_final_submission_files, created_at: Time.zone.now }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }
  let(:committee_role) { FactoryBot.create :committee_role, name: "Dissertation Advisor/Co-Advisor" }
  let(:approval_configuration) { FactoryBot.create :approval_configuration }
  let!(:committee_member) { FactoryBot.create :committee_member, committee_role: committee_role, approval_started_at: DateTime.now, submission: submission, status: '', access_id: 'approverflow' }
  let!(:committee_member2) { FactoryBot.create :committee_member, committee_role: committee_role, approval_started_at: DateTime.now, submission: submission1, status: '', access_id: 'approverflow' }

  before do
    submission.final_submission_files << final_submission_file
    submission.degree.degree_type.approval_configuration = approval_configuration
    oidc_authorize_approver
  end

  it "updates approver's committee member records and lists them" do
    expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 0
    visit '/approver/reviews'
    expect(page).to have_link('walkthrough')
    expect(page).to have_content('Contact Us')
    expect(page).to have_content('My Reviews')
    expect(page).to have_content('Submission Title')
    expect(page).to have_content('Author')
    expect(page).to have_content('Review Started On')
    expect(page).to have_content('My Review')
    expect(page).to have_content('Submission Status')
    expect(page).to have_content('Search:')
    expect(page).to have_content('Showing 1 to 1 of 1 entries')
    sorted_column = find('th', text: 'Review Started On', class: 'sorting_desc')
    expect(sorted_column).to be_present
    expect(page).to have_content('Waiting For Committee Review')
    expect(page).to have_content("#{submission.author.first_name} #{submission.author.last_name}")
    expect(page).to have_content(CommitteeMember.find(committee_member.id).approval_started_at.strftime('%m/%d/%Y'))
    expect(page).to have_link(submission.title)
    expect(page).not_to have_link(submission1.title)
    expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 2
  end

  it 'can visit a single committee member review' do
    visit '/approver/reviews'
    click_on submission.title
    expect(page).to have_current_path(approver_path(committee_member))
  end

  it 'can filter on completeness of submissions' do
    completed_submission = FactoryBot.create :submission, :waiting_for_publication_release, created_at: Time.zone.now, final_submission_files_uploaded_at: DateTime.now, final_submission_approved_at: DateTime.now
    FactoryBot.create :committee_member, committee_role: committee_role, submission: completed_submission, status: 'Approved', access_id: 'approverflow'
    visit '/approver/reviews'
    expect(page).to have_link(submission.title)
    expect(page).not_to have_link(completed_submission.title)
    select 'Finished Reviews', from: 'reviews-select'
    expect(page).not_to have_link(submission.title)
    expect(page).to have_link(completed_submission.title)
    select 'All Reviews', from: 'reviews-select'
    expect(page).to have_link(submission.title)
    expect(page).to have_link(completed_submission.title)
    select 'Active Reviews', from: 'reviews-select'
    expect(page).to have_link(submission.title)
    expect(page).not_to have_link(completed_submission.title)
  end
end
