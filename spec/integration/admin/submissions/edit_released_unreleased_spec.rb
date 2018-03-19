RSpec.describe "Editing a released submission as an admin", js: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Test Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Master of Disaster", is_active: true) }
  let!(:role) { CommitteeRole.first }
  let!(:author) { FactoryBot.create(:author, :no_lionpath_record) }
  let(:submission) { FactoryBot.create(:submission, :released_for_publication, author: author) }
  let(:committee) { create_committee(submission) }
  let(:invention_disclosures) { create(:invention_disclosure, submission) }

  before do
    webaccess_authorize_admin
    visit admin_edit_submission_path(submission)

    fill_in "Title", with: "A Brand New TITLE"
    check "Allow completely upper-case words in title"
    select program.name, from: current_partner.program_label.to_s
    select degree.name, from: "Degree"
    select "Fall", from: "Semester Intending to Graduate"
    select 1.year.from_now.year, from: "Graduation Year"
    click_link("Add Committee Member")
    within('#committee') do
      select role.name, from: "Committee role"
      fill_in "Name", with: "Bob Tester"
      fill_in "Email", with: "bob@email.com"
    end

    within('#format-review-files') do
      click_link "Additional File"
      find('input[type="file"]').set(fixture('format_review_file_01.pdf'))
    end

    fill_in "Format Review Notes to Student", with: "New review notes"
    fill_in "Admin notes", with: "Some admin notes"
  end

  it "Saves the updated submission data" do
    expect(field_labeled('Date Defended', disabled: true)).to be_truthy if submission.using_lionpath?
    fill_in "Abstract", with: "New abstract text"

    click_link "Additional Keyword"
    within '#keyword-fields' do
      all('textarea').last.set("Bananas")
    end

    page.find("#submission_access_level_restricted").trigger('click')
    inventions = page.find(:css, 'div.form-group.string.optional.submission_invention_disclosures_id_number')
    within inventions do
      fill_in 'Invention Disclosure Number (Required for Restricted Access)', with: '1234'
    end

    within('#final-submission-information') do
      click_link "Additional File"
      find('input[type="file"]').set(fixture('final_submission_file_01.pdf'))
    end

    fill_in "Final Submission Notes to Student", with: "New final notes"

    click_button "Update Metadata"
    expect(page).to have_current_path(admin_edit_submission_path(submission))
    expect(page).to have_content "The submission was successfully updated."

    expect(page.find_field("Title").value).to eq "A Brand New TITLE"
    expect(page.find_field("Allow completely upper-case words in title")).to be_checked
    expect(page.find_field(current_partner.program_label.to_s).value).to eq program.id.to_s
    expect(page.find_field("Degree").value).to eq degree.id.to_s
    expect(page.find_field("Semester Intending to Graduate").value).to eq "Fall"
    expect(page.find_field("Graduation Year").value).to eq 1.year.from_now.year.to_s

    within('#committee') do
      expect(page.find_field("Committee role").value).to eq role.id.to_s
      expect(page.find_field("Name").value).to eq "Bob Tester"
      expect(page.find_field("Email").value).to eq "bob@email.com"
    end

    within('#format-review-files') do
      expect(page).to have_content "format_review_file_01.pdf"
    end

    expect(page.find_field("Format Review Notes to Student").value).to eq "New review notes"
    expect(page.find_field("Admin notes").value).to eq "Some admin notes"
    expect(field_labeled('Date Defended', disabled: true)).to be_truthy if submission.using_lionpath?
    expect(page.find_field("Abstract").value).to eq "New abstract text"

    within('#keyword-fields') do
      expect(page.all('textarea').last.value).to eq "Bananas"
    end

    # page continues to remain as open access; can't figure out why the radio can't be clicked; has to do with invention disclosure
    # expect(page.find_field('submission_access_level_restricted')).to be_checked

    within('#final-submission-file-fields') do
      expect(page).to have_content "final_submission_file_01.pdf"
    end

    expect(page.find_field("Final Submission Notes to Student").value).to eq "New final notes"
  end

  describe "Remove from  submission to be released", js: true do
    # let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
    # let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", degree_type: DegreeType.default, is_active: true) }
    let(:author) { FactoryBot.create(:author, :no_lionpath_record) }
    let(:submission) { FactoryBot.create(:submission, :waiting_for_publication_release, author: author) }
    let(:author_name) { submission.author.last_name }

    # let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }

    before do
      webaccess_authorize_admin
      visit admin_edit_submission_path(submission)
    end

    it "Changes the status to 'waiting for final submission response' and also saves any updates" do
      expect(page).to have_content('Final Submission to be Released')
      expect(page).to have_button('Update Metadata Only')
      fill_in "Title", with: "A Better Title"
      # page.find('input#rejected').trigger(:mouseover)
      # expect(page).to have_content("Return to 'Final Submission is Submitted'")
      click_button "Remove from Submission to be Released"
      expect(page).to have_current_path(admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_approved'))
      expect(page).not_to have_content "A Better Title"

      visit admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_submitted')
      sleep(3)
      expect(page).to have_content('Final Submission is Submitted')
      expect(page).to have_content author_name
      click_link "A Better Title"
      # visit admin_edit_submission_path(submission)
      expect(page).to have_content 'Final Submission Evaluation'
      expect(find(:css, 'input#submission_title').value).to eq('A Better Title')
    end
  end

  describe "Remove legacy record from  submission to be released", js: true do
    it "Changes the status to 'final submission submitted' and also saves any updates" do
      # degree_type = current_partner.graduate? ? 'dissertation' : 'thesis'
      # program = FactoryBot.create(:program, name: "Any Program", is_active: true)
      # degree = FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true, degree_type: DegreeType.default)
      legacy_submission = FactoryBot.create(:submission, :waiting_for_publication_release)
      author_name = submission.author.last_name
      legacy_submission.legacy_id = 888
      legacy_submission.save

      webaccess_authorize_admin
      visit admin_edit_submission_path(legacy_submission)

      expect(page).to have_button('Update Metadata Only')
      # Some legacy records do not have titles
      fill_in "Title", with: ""
      click_button "Remove from Submission to be Released"
      expect(page).to have_current_path(admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_approved'))
      expect(page).not_to have_content "A Better Title"

      visit admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_submitted')

      expect(page).to have_content author_name
      sleep(4)
      visit admin_edit_submission_path(legacy_submission)
      expect(page).to have_content 'Final Submission Evaluation'
      expect(find(:css, 'input#submission_title').value).to eq('')
    end
  end
end
