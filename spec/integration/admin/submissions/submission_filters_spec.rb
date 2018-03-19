RSpec.describe "Submission filter with semester dropdown", js: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  # let!(:degree) { create (:degree) }
  let!(:role) { CommitteeRole.first.name }
  let(:submission1) { FactoryBot.create(:submission, :waiting_for_final_submission_response) }
  let(:submission2) { FactoryBot.create(:submission, :waiting_for_final_submission_response) }
  let(:author_name) { submission.author.last_name }
  let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { DegreeType.default }
  let(:submission_year) { '2025' }
  let(:submission_semester) { 'Spring' }

  before do
    submission1.semester = submission_semester
    submission1.year = submission_year
    submission1.access_level = 'restricted'
    submission1.invention_disclosures = [InventionDisclosure.new(id_number: "#{submission_year}-1234")]
    submission1.save!
    submission2.semester = submission_semester
    submission2.year = submission_year
    submission2.save!
    webaccess_authorize_admin
    # visit admin_edit_submission_path(submission)
    visit admin_submissions_dashboard_path(DegreeType.default.name)
  end

  it 'displays the submission dashboard page with link to final submission is submitted page' do
    expect(page).to have_content(DegreeType.default.name)
    expect(page).to have_content('Final Submission is Submitted')
    expect(page).to have_content('2')
  end

  it 'opens the final submission submitted page' do
    page.find('a#final-submission-submitted').click
    sleep(3)
    expect(page).to have_selector('h1', text: 'Final Submission is Submitted')
    expect(page).to have_selector('.form-control.input-sm.semester')
    expect(page).to have_select('All Semesters')
    semester_year = "#{submission1.year} #{submission1.semester}"
    expect(page).to have_select(semester_year)
    expect(page).not_to have_select('2016 Spring')
  end
  it 'displays access level and invention disclosure' do
    page.find('a#final-submission-submitted').click
    sleep(3)
    expect(page).to have_content('Restricted')
    expect(page).to have_content("#{submission_year}-1234")
  end
end
