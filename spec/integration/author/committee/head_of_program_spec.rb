RSpec.describe 'The standard committee form for authors', js: true do
  require 'integration/integration_spec_helper'

  let(:author) { current_author }
  let(:submission) { FactoryBot.create :submission, :collecting_committee, author: author, degree: degree }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: true }

  before do
    webaccess_authorize_author
    visit new_author_submission_committee_members_path(submission)
  end

  it 'fills in head of program page' do
    submission.required_committee_roles.count.times do |i|
      next if i == 0

      fill_in "submission_committee_members_attributes_#{i}_name", with: "Name #{i}"
      page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'name_#{i}@example.com'")
    end
    click_button 'Save and Input Head/Chair of Graduate Program >>'
    expect(page).to have_content 'Input Head/Chair of Graduate Program'
    fill_in "submission_committee_members_attributes_5_name", with: "Name 5"
    page.execute_script("document.getElementById('submission_committee_members_attributes_5_email').value = 'name_5@example.com'")
    click_button 'Update Head/Chair of Graduate Program Information'
    expect(page).to have_current_path(author_root_path)
    expect(CommitteeMember.head_of_program(submission.id).name).to eq 'Name 5'
  end

  it 'validates and returns to dashboard' do
    submission.required_committee_roles.count.times do |i|
      next if i == 0

      fill_in "submission_committee_members_attributes_#{i}_name", with: "Name #{i}"
      page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'name_#{i}@example.com'")
    end
    click_button 'Save and Input Head/Chair of Graduate Program >>'
    expect(page).to have_content 'Input Head/Chair of Graduate Program'
    click_button 'Update Head/Chair of Graduate Program Information'
    expect(page).to have_current_path(author_submission_head_of_program_path(submission))
    expect(CommitteeMember.head_of_program(submission.id)).to eq nil
    click_link 'Return to dashboard'
    expect(page).to have_current_path(author_root_path)
    expect(CommitteeMember.head_of_program(submission.id)).to eq nil
  end
end
