RSpec.describe "filtering with semester dropdown", js: true do
  require 'integration/integration_spec_helper'

  let!(:submission1) do
    FactoryBot.create(:submission, :released_for_publication,
                      semester: Semester.current.split(" ")[1],
                      year: Semester.current.split(" ")[0])
  end

  let!(:submission2) do
    FactoryBot.create(:submission, :released_for_publication,
                      semester: Semester.current.split(" ")[1],
                      year: Semester.current.split(" ")[0].to_f - 2)
  end

  let!(:submission3) do
    FactoryBot.create(:submission, :waiting_for_committee_review,
                      semester: Semester.current.split(" ")[1],
                      year: Semester.current.split(" ")[0].to_f - 2)
  end

  let!(:degree_type) { DegreeType.default }

  before do
    webaccess_authorize_admin
    visit admin_submissions_dashboard_path(DegreeType.default.name)
  end

  context "when selecting 'Released Theses' bucket" do
    it 'defaults to current semester and can filter by semester' do
      page.find('a#released-for-publication').click
      expect(page).to have_content Semester.current
      expect(page).to have_content submission1.title
      expect(page).not_to have_content submission2.title
      find('select.semester').find(:option, "#{submission2.year} #{submission2.semester}").select_option
      expect(page).not_to have_content submission1.title
      expect(page).to have_content submission2.title
      find('select.semester').find(:option, "All Semesters").select_option
      expect(page).to have_content submission1.title
      expect(page).to have_content submission2.title
    end
  end
end
