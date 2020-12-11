RSpec.describe "Editing committee member information", js: true, honors: true, milsch: true do
  require 'integration/integration_spec_helper'

  let!(:author) { FactoryBot.create(:author) }
  let!(:submission) { FactoryBot.create(:submission, :waiting_for_committee_review, degree: degree, author: author) }
  let!(:degree) { FactoryBot.create(:degree, degree_type: DegreeType.default) }
  let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: DegreeType.default }

  before do
    create_committee submission
    submission.committee_members << FactoryBot.create(:committee_member)
    webaccess_authorize_admin
  end

  it 'has specific content and records changes for certain updates', retry: 5 do
    visit admin_edit_submission_path(submission)
    committee_size = submission.committee_members.count
    find("div[data-target='#committee']").click
    sleep 1
    within('#committee') do
      within("select#submission_committee_members_attributes_0_committee_role_id") do
        CommitteeRole.where(degree_type: degree.degree_type).each do |option|
          expect(find("option[value='#{option[:id]}']").text).to eq(option[:name])
        end
      end
      last_committee_member_remove = find_all("a", text: "Remove Committee Member").last
      find("select#submission_committee_members_attributes_0_status").find(:option, 'Approved').select_option
      last_committee_member_remove.trigger('click')
    end
    click_button 'Update Metadata'
    submission.reload
    puts page.body
    find("div[data-target='#committee']").click
    sleep 1
    within('#committee') do
      expect(page).to have_content("Approved at: ")
    end
    expect(submission.committee_members.count).to eq(committee_size.to_i - 1)
    expect(submission.committee_members.first.status).to eq 'approved'
    expect(submission.committee_members.first.notes).to match(/changed Review Status to 'Approved'/)
  end
end
