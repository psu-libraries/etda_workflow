RSpec.describe "Released submission filter with semester dropdown", js: true do
  require 'integration/integration_spec_helper'

  let!(:submission1) { FactoryBot.create(:submission, :released_for_publication, semester: Semester.current.split(" ")[1], year: Semester.current.split(" ")[0]) }
  let!(:submission2) { FactoryBot.create(:submission, :released_for_publication, semester: Semester.current.split(" ")[1], year: Semester.current.split(" ")[0].to_f - 2) }
  let!(:degree_type) { DegreeType.default }

  before do
    webaccess_authorize_admin
    visit admin_submissions_dashboard_path(DegreeType.default.name)
  end

  it 'defaults to current semester and can filter by semester' do
    page.find('a#released-for-publication').click
    sleep 1
    expect(page).to have_content submission1.title
    expect(page).not_to have_content submission2.title
    find('select.semester').find(:option, "#{submission2.year} #{submission2.semester}").select_option
    sleep 1
    expect(page).not_to have_content submission1.title
    expect(page).to have_content submission2.title
    find('select.semester').find(:option, "All Semesters").select_option
    sleep 1
    expect(page).to have_content submission1.title
    expect(page).to have_content submission2.title
  end
end
