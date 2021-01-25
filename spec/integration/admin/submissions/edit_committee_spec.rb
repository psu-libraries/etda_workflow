RSpec.describe "Editing committee member information for format reviews and final submissions", js: true, honors: true, milsch: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Test Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Master of Disaster", is_active: true) }
  let!(:approval_configuration) { FactoryBot.create(:approval_configuration, degree_type: degree.degree_type, use_percentage: false, configuration_threshold: 0) }
  let!(:role) { CommitteeRole.first }
  let!(:author) { FactoryBot.create(:author, :no_lionpath_record) }
  let(:submission) { FactoryBot.create(:submission, :waiting_for_committee_review, author: author) }

  before do
    create_committee submission
    submission.committee_members << FactoryBot.create(:committee_member, committee_role: role) unless current_partner.graduate?
    submission.committee_members << FactoryBot.create(:committee_member, committee_role: role) unless current_partner.graduate?
    oidc_authorize_admin
  end

  it 'has specific content and records changes for certain updates', retry: 5 do
    visit admin_edit_submission_path(submission)
    committee_size = submission.committee_members.count
    find("div[data-target='#committee']").click
    sleep 1
    within('#committee') do
      expect(find("select[id='submission_committee_members_attributes_0_committee_role_id']").value).to eq role.id.to_s
      within("select#submission_committee_members_attributes_1_committee_role_id") do
        CommitteeRole.where(degree_type: degree.degree_type).each do |option|
          expect(find("option[value='#{option[:id]}']").text).to eq(option[:name])
        end
      end
      first_committee_member_remove = find_all("a", text: "Remove Committee Member").first
      find("select#submission_committee_members_attributes_1_status").find(:option, 'Approved').select_option
      first_committee_member_remove.trigger('click')
    end
    click_button 'Update Metadata'
    submission.reload
    expect(page).to have_content("Waiting for Committee Review")
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
