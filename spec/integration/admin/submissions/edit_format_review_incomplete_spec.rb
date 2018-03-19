RSpec.describe "Editing an incomplete submission as an admin", js: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Test Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Master of Disaster", is_active: true) }
  let!(:role) { CommitteeRole.first }
  let!(:author) { FactoryBot.create(:author, :no_lionpath_record) }
  let(:submission) { FactoryBot.create(:submission, :collecting_program_information, author: author) }
  let(:admin) { FactoryBot.create :admin }

  before do
    webaccess_authorize_admin
    visit admin_edit_submission_path(submission)

    fill_in "Title", with: "A Brand New TITLE"
    check "Allow completely upper-case words in title"
    select program.name, from: current_partner.program_label.to_s
    select degree.name, from: "Degree"
    select "Fall", from: "Semester Intending to Graduate"
    select 1.year.from_now.year, from: "Graduation Year"

    click_link "Add Committee Member"
    within('#committee') do
      select role.name, from: "Committee role"
      fill_in "Name", with: "Bob Tester"
      fill_in "Email", with: "bob@email.com"
    end

    within('#format-review-files') do
      click_link "Additional File"
      all('input[type="file"]').first.set(fixture('format_review_file_01.pdf'))
      all('input[type="file"]').last.set(fixture('format_review_file_01.pdf'))
    end

    fill_in "Format Review Notes to Student", with: "New review notes"
    fill_in "Admin notes", with: "Some admin notes"

    click_button "Update Metadata"
  end

  it "Saves the updated submission data" do
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
  end
end
