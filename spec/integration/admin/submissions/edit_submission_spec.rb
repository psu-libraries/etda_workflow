RSpec.describe "Editing format review and final submissions as an admin", :js, type: :integration do
  require 'integration/integration_spec_helper'

  let!(:author) { FactoryBot.create(:author) }
  let!(:program) { FactoryBot.create(:program, name: "Test Program", is_active: true) }
  let!(:degree_type) { DegreeType.find_by(slug: 'master_thesis') }
  let!(:masters_degree) { FactoryBot.create :degree, degree_type: }
  let!(:degree) { FactoryBot.create(:degree, name: "Master of Disaster", is_active: true) }
  let!(:approval_configuration) { FactoryBot.create(:approval_configuration, degree_type: degree.degree_type) }
  let!(:role) { CommitteeRole.second }
  let!(:submission) do
    FactoryBot.create(:submission,
                      :collecting_committee,
                      author:,
                      program:,
                      semester: 'Spring')
  end
  let!(:admin) { FactoryBot.create :admin }
  let!(:final_submission) { FactoryBot.create(:submission, :waiting_for_final_submission_response, author:) }
  let!(:final_masters_submission) do
    FactoryBot.create(:submission, :waiting_for_final_submission_response, author:, degree: masters_degree)
  end

  before do
    stub_request(:post, "https://etda.localhost:3000/solr/update?wt=json")
    oidc_authorize_admin
  end

  describe 'lionpath display variations' do
    context 'when submission is imported from lionpath' do
      it 'displays disabled program info' do
        submission.update lionpath_updated_at: DateTime.now
        visit admin_edit_submission_path(submission)
        expect(find("select#submission_program_id").disabled?).to be true
        expect(find("select#submission_degree_id").disabled?).to be true
        expect(find("select#submission_lionpath_semester").disabled?).to be true
        expect(find("select#submission_semester").disabled?).to be false
        expect(find("select#submission_lionpath_year").disabled?).to be true
        expect(find("select#submission_year").disabled?).to be false
        expect(page).to have_content "LionPath Imported Semester Intending to Graduate"
        expect(page).to have_content "LionPath Imported Graduation Year"
        expect(page).to have_content "Author Submitted Semester Intending to Graduate"
        expect(page).to have_content "Author Submitted Graduation Year"
      end
    end

    context 'when submission is not imported from lionpath' do
      it 'does not disable program data and does not show any lionpath fields' do
        visit admin_edit_submission_path(submission)
        expect(find("select#submission_program_id").disabled?).to be false
        expect(find("select#submission_degree_id").disabled?).to be false
        expect(page).not_to have_content "LionPath Imported Semester Intending to Graduate"
        expect(page).not_to have_content "LionPath Imported Graduation Year"
        expect(page).not_to have_content "Author Submitted Semester Intending to Graduate"
        expect(page).not_to have_content "Author Submitted Graduation Year"
      end
    end
  end

  it "Saves the updated submission data for a submission with status collecting committee", retry: 5 do
    visit admin_edit_submission_path(submission)
    check "Allow completely upper-case words in title"
    fill_in "Title", with: "A Brand New TITLE"
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
    end
    within('#format-review-file-fields') do
      all('input[type="file"]')[0].set(file_fixture('format_review_file_01.pdf'))
      all('input[type="file"]')[1].set(file_fixture('format_review_file_02.pdf'))
    end
    within('#admin-feedback-files') do
      all('input[type="file"]')[0].set(file_fixture('admin_feedback_01.pdf'))
    end

    find("#submission_federal_funding_details_attributes_training_support_funding_true").click
    find("#submission_federal_funding_details_attributes_other_funding_false").click
    find("#submission_federal_funding_details_attributes_training_support_acknowledged_true").click

    fill_in "Format Review Notes to Student", with: "New review notes"
    fill_in "Admin notes", with: "Some admin notes"

    click_button "Update Metadata"
    visit admin_edit_submission_path(submission)
    expect(page).to have_current_path(admin_edit_submission_path(submission))
    expect(page.find_field("Title").value).to eq "A Brand New TITLE"
    expect(page.find_field("Allow completely upper-case words in title")).to be_checked
    expect(page.find_field(current_partner.program_label.to_s).value).to eq program.id.to_s
    expect(page.find_field("Degree").value).to eq degree.id.to_s
    expect(page.find_field("Semester Intending to Graduate").value).to eq "Fall"
    expect(page.find_field("Graduation Year").value).to eq 1.year.from_now.year.to_s
    expect(page.find_field("submission_federal_funding_details_attributes_training_support_funding_true")).to be_checked
    expect(page.find_field("submission_federal_funding_details_attributes_other_funding_false")).to be_checked
    expect(page.find_field("submission_federal_funding_details_attributes_training_support_acknowledged_true")).to be_checked

    within('#committee') do
      expect(page.find_field("Committee role").value).to eq role.id.to_s
      expect(page.find_field("Name").value).to eq "Bob Tester"
      expect(page.find_field("Email").value).to eq "bob@email.com"
    end

    within('#format-review-files') do
      expect(page).to have_link "format_review_file_01.pdf"
      expect(page).to have_link "format_review_file_02.pdf"
    end

    within('#admin-feedback-files') do
      expect(page).to have_link "admin_feedback_01.pdf"
    end

    expect(page.find_field("Format Review Notes to Student").value).to eq "New review notes"
    expect(page.find_field("Admin notes").value).to eq "Some admin notes"

    within('#format-review-file-fields') do
      delete_link = find_all('a#file_delete_link').first
      delete_link.click
    end
    expect(page).to have_content("Marked for deletion [undo]")
    click_button 'Update Metadata'
    visit admin_edit_submission_path(submission)
    expect(page).to have_link "format_review_file_02.pdf"
    expect(page).not_to have_link "format_review_file_01.pdf"

    within('#admin-feedback-files') do
      delete_link = find_all('a#file_delete_link').first
      delete_link.click
    end
    click_button 'Update Metadata'
    visit admin_edit_submission_path(submission)
    expect(page).not_to have_link "admin_feedback_01.pdf"
  end

  it 'Allows admin to upload and delete final submission files' do
    visit admin_edit_submission_path(final_submission)
    expect(page).not_to have_link('final_submission_file_01.pdf')
    within('#final-submission-information') do
      click_link "Additional File"
      all('input[type="file"]').first.set(file_fixture('final_submission_file_01.pdf'))
      click_link "Add File"
      all('input[type="file"]').last.set(file_fixture('admin_feedback_01.pdf'))
    end
    click_button 'Update Metadata'
    visit admin_edit_submission_path(final_submission)
    expect(page).to have_link('final_submission_file_01.pdf')
    expect(page).to have_link('admin_feedback_01.pdf')
    within('#final-submission-information') do
      delete_links = find_all('a#file_delete_link')
      delete_link = delete_links.first
      delete_link2 = delete_links.last
      delete_link.click
      delete_link2.click
    end
    expect(page).to have_content("Marked for deletion [undo]")
    click_button 'Update Metadata'
    visit admin_edit_submission_path(final_submission)
    expect(page).not_to have_link('final_submission_file_01.pdf')
    expect(page).not_to have_link('admin_feedback_01.pdf')
  end

  it 'Allows admin to upload multiple final submission files' do
    visit admin_edit_submission_path(final_submission)
    expect(page).not_to have_link('final_submission_file_01.pdf')
    expect(page).not_to have_link('final_submission_file_01.pdf')
    within('#final-submission-information') do
      click_link "Additional File"
      all('input[type="file"]').first.set(file_fixture('final_submission_file_01.pdf'))

      click_link "Additional File"
      all('input[type="file"]').last.set(file_fixture('final_submission_file_01.pdf'))
    end
    click_button 'Update Metadata'
    visit admin_edit_submission_path(final_submission)
    expect(page).to have_link('final_submission_file_01.pdf')
    expect(page).to have_link('final_submission_file_01.pdf')
    within('#final-submission-information') do
      delete_link = find_all('a#file_delete_link').first
      delete_link.click
    end
    expect(page).to have_content("Marked for deletion [undo]")
    click_button 'Update Metadata'
    visit admin_edit_submission_path(final_submission)
    expect(page).to have_link('final_submission_file_01.pdf')
  end

  it 'Allows admin to edit final submission content' do
    visit admin_edit_submission_path(final_submission)
    within('#final-submission-information') do
      expect(page.find_field("Final Submission Notes to Student").value).to eq(I18n.t('graduate.default_final_submission_note'))
      click_link "Additional File"
      all('input[type="file"]').first.set(file_fixture('final_submission_file_01.pdf'))
    end
    find('#submission_access_level_restricted').click
    find('#submission_proquest_agreement').click if current_partner.graduate?

    find("#submission_federal_funding_details_attributes_training_support_funding_false").click
    find("#submission_federal_funding_details_attributes_other_funding_false").click

    fill_in 'submission_invention_disclosures_attributes_0_id_number', with: 12345
    fill_in 'Admin notes', with: 'Some Notes', exact: true
    click_button 'Update Metadata'
    sleep 1
    final_submission.reload
    expect(final_submission.admin_notes).to eq 'Some Notes'
    expect(final_submission.federal_funding).to be false
    expect(final_submission.restricted?).to be true
    expect(final_submission.proquest_agreement).to be false if current_partner.graduate?
  end

  context "when master's thesis" do
    let!(:approval_configuration2) do
      FactoryBot.create(:approval_configuration, degree_type: masters_degree.degree_type)
    end

    it 'does not show ProQuest agreement' do
      skip 'graduate only' unless current_partner.graduate?

      visit admin_edit_submission_path(final_masters_submission)
      expect(page).not_to have_content('ProQuest Statement')
    end
  end

  describe 'has link to audit page' do
    let!(:file) { FactoryBot.create :final_submission_file, submission: final_submission }

    it 'directs to audit page with audit content' do
      visit admin_edit_submission_path(final_submission)
      click_link 'View Printable Audit'
      expect(page).to have_content("#{final_submission.degree.degree_type.name} Audit")
      expect(page).to have_link(file.asset_identifier.to_s)
      expect(page).to have_content("Committee Approval Status:")
      expect(page).to have_content("Committee Member Reviews")
      expect(page).to have_content("Approved at")
    end
  end
end
