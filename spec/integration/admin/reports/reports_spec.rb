RSpec.describe "Admins can run reports", :js, type: :integration do
  require 'integration/integration_spec_helper'

  submission_year = Semester.current.split[0]
  submission_semester = Semester.current.split[1]
  let(:degree_type1) { DegreeType.first }
  let(:degree_type2) { DegreeType.last }
  let!(:author1) do
    FactoryBot.create :author,
                      access_id: 'xyz321',
                      psu_email_address: 'xyz321@psu.edu',
                      first_name: 'Author',
                      last_name: 'One'
  end
  let!(:author2) do
    FactoryBot.create :author,
                      access_id: 'abc987',
                      psu_email_address: 'abc987@psu.edu',
                      first_name: 'Author',
                      last_name: 'Two'
  end
  let!(:author3) do
    FactoryBot.create :author,
                      access_id: 'abc123',
                      psu_email_address: 'abc123@psu.edu',
                      first_name: 'Author',
                      last_name: 'Three',
                      confidential_hold: 1,
                      confidential_hold_set_at: DateTime.now
  end
  let!(:degree1) do
    FactoryBot.create :degree,
                      degree_type_id: degree_type1.id,
                      name: 'PHD',
                      description: 'PHD',
                      is_active: true
  end
  let!(:degree2) do
    FactoryBot.create :degree,
                      degree_type_id: degree_type2.id,
                      name: 'MS',
                      description: 'MS',
                      is_active: true
  end
  let!(:submission1) do
    FactoryBot.create :submission,
                      :released_for_publication,
                      author: author1,
                      year: submission_year,
                      semester: submission_semester,
                      title: 'Submission1',
                      degree_id: degree1.id,
                      access_level: 'open_access',
                      admin_notes: 'Some Admin Notes'
  end
  let!(:submission2) do
    FactoryBot.create :submission,
                      :released_for_publication,
                      author: author2,
                      year: submission_year,
                      semester: submission_semester,
                      title: 'Submission2',
                      degree_id: degree1.id,
                      access_level: 'restricted'
  end
  let!(:submission3) do
    FactoryBot.create :submission,
                      :waiting_for_format_review_response,
                      author: author2,
                      year: submission_year,
                      semester: submission_semester,
                      title: 'Submission3',
                      program: (FactoryBot.create :program, name: 'Test'),
                      degree_id: degree2.id
  end
  let!(:submission4) do
    FactoryBot.create :submission,
                      :released_for_publication,
                      author: author3,
                      year: (submission_year.to_i + 1).to_s,
                      semester: submission_semester,
                      title: 'Submission2',
                      degree_id: degree1.id,
                      access_level: 'restricted'
  end

  before do
    create_committee(submission1)
    create_committee(submission2)
    submission1.committee_members.first.update(name: 'Professor Thesis Advisor Test', email: 'professor@thesis.advisor') if current_partner.honors?
    submission2.access_level = 'restricted'
    oidc_authorize_admin
    visit admin_submissions_dashboard_path(Degree.first.degree_type)
  end

  context('Report link is visible on left navigation') do
    it 'contains a report link on the main navigation' do
      expect(page).to have_link('Reports')
      expect(page).not_to have_link('Committee Report')
    end
  end

  context 'clicking on Report link', :js do
    it 'displays the available report types' do
      expect(page).to have_link('Reports')
      page.find('a#reports_menu').click
      expect(page).to have_link('Custom Report')
      expect(page).to have_link('Confidential Hold Report')
    end
  end

  context 'custom report page' do
    before do
      submission2.access_level = 'restricted'
      submission2.save
      visit admin_submissions_dashboard_path(DegreeType.first)
      click_link('Reports')
    end

    it 'displays the access level' do
      expect(page).to have_link('Custom Report')
      click_link('Custom Report')
      expect(page).to have_content('Restricted')
    end

    it 'displays the Custom Report page and allows filtering by semester', :graduate, :honors do
      expect(page).to have_link('Custom Report')
      click_link('Custom Report')
      expect(page).to have_content('Custom Report')
      expect(page).to have_button('Select Visible')
      expect(page).to have_content(author1.last_name)
      expect(page).to have_content(author2.last_name)
      expect(page).not_to have_content(author3.last_name)
      expect(page).to have_content(submission2.program.name)
      expect(page).to have_content(submission1.admin_notes)
      if current_partner.graduate?
        expect(page).not_to have_content(submission3.program.name)
        expect(page).not_to have_content('Professor Thesis Advisor Test')
        expect(page).not_to have_content('professor@thesis.advisor')
      elsif current_partner.honors?
        expect(page).to have_content('Thesis Supervisor')
        supervisor_index = find_all('th').map(&:text).find_index("Thesis Supervisor")
        thesis_supervisor_name = find_all('td')[supervisor_index].text
        expect(thesis_supervisor_name).to eq('Professor Thesis Advisor Test')
        expect(page).to have_content("Thesis Supervisor Email")
        email_index = find_all('th').map(&:text).find_index("Thesis Supervisor Email")
        thesis_supervisor_email = find_all('td')[email_index].text
        expect(thesis_supervisor_email).to eq('professor@thesis.advisor')
      end
      click_button 'Select Visible'
      page.assert_selector('tbody .row-checkbox')
      ckbox = all('tbody .row-checkbox')
      assert_equal(Submission.where(year: submission_year,
                                    semester: submission_semester)
                       .select { |s| s.degree_type == degree_type1 }.count, ckbox.count)
      ckbox.each do |cb|
        expect(have_checked_field(cb)).to be_truthy
      end
      select "#{submission4.preferred_year} #{submission4.preferred_semester}", from: 'submission_semester_year'
      expect(page).to have_content(author3.last_name)
      expect(page).not_to have_content(author1.last_name)
      expect(page).not_to have_content(author2.last_name)
      click_button 'Select Visible'
      expect(page).to have_button('Export CSV')
      click_button('Export CSV')
    end

    it 'allows filtering by degree type' do
      click_link('Custom Report')
      sleep 1
      select degree_type2.name, from: 'submission_degree_type'
      expect(page).to have_content(submission3.program.name)
    end
  end

  context 'confidential hold report index' do
    before do
      author3.submissions << submission1
      visit admin_submissions_dashboard_path(DegreeType.first)
      click_link('Reports')
      click_link('Confidential Hold Report')
    end

    it 'displays the confidential hold report' do
      expect(page).to have_content('Confidential Hold Report')
      expect(page).to have_content(author3.psu_email_address)
      click_button('Select Visible')
      expect(page).to have_button('Export CSV')
      click_button 'Export CSV'
    end

    it "links to author's page" do
      click_link author3.access_id
      expect(page).to have_current_path(edit_admin_author_path(author3))
    end
  end
end
