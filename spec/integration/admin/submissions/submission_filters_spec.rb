RSpec.describe "Submission filter with semester dropdown", :js, type: :integration do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:submission1) { FactoryBot.create(:submission, :waiting_for_final_submission_response, semester: Semester.current.split(" ")[1], year: Semester.current.split(" ")[0]) }
  let(:submission2) { FactoryBot.create(:submission, :waiting_for_final_submission_response, semester: Semester.current.split(" ")[1], year: Semester.current.split(" ")[0]) }
  let(:degree_type) { DegreeType.default }

  before do
    submission1.access_level = 'restricted'
    submission1.invention_disclosures = [InventionDisclosure.new(id_number: "#{submission1.year}-1234")]
    submission1.save!
    oidc_authorize_admin
    visit admin_submissions_dashboard_path(DegreeType.default.name)
  end

  it 'displays the submission dashboard page with link to final submission is submitted page' do
    expect(page).to have_content(DegreeType.default.name)
    expect(page).to have_content('Final Submission is Submitted')
    expect(page).to have_content('2')
  end

  it 'opens the final submission submitted page' do
    page.find('a#final-submission-submitted').click
    expect(page).to have_selector('h1', text: 'Final Submission is Submitted')
    expect(page).to have_selector('.form-control.input-sm.semester')
    expect(page).to have_select('All Semesters')
    semester_year = "#{submission1.year} #{submission1.semester}"
    expect(page).to have_select(semester_year)
    expect(page).not_to have_select("#{submission1.year - 6} Spring")
  end

  it 'displays access level and invention disclosure' do
    page.find('a#final-submission-submitted').click
    expect(page).to have_content('Restricted')
    expect(page).to have_content("#{submission1.year}-1234")
  end
end
