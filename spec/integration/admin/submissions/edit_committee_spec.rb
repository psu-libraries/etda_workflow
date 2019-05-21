RSpec.describe "Editing committee member information for format reviews and final submissions", js: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Test Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Master of Disaster", is_active: true) }
  let!(:approval_configuration) { FactoryBot.create(:approval_configuration, degree_type: degree.degree_type) }
  let!(:role) { CommitteeRole.first }
  let!(:author) { FactoryBot.create(:author, :no_lionpath_record) }
  let(:submission) { FactoryBot.create(:submission, :waiting_for_committee_review, author: author) }
  let(:admin) { FactoryBot.create :admin }

  before do
    create_committee submission
    webaccess_authorize_admin
  end

  context 'when partner is graduate' do
    it 'has Head/Chair of Graduate Program' do
      visit admin_edit_submission_path(submission)
      sleep 3
      find("div[data-target='#committee']").click
      within('#committee') do
        expect(find("select[id='submission_committee_members_attributes_0_committee_role_id']").value).to eq role.id.to_s
        expect(find("select[id='submission_committee_members_attributes_0_committee_role_id']").disabled?).to eq true
        expect{ find("label[for='submission_committee_members_attributes_0_Is voting on approval']") }.to raise_error Capybara::ElementNotFound
        expect(find("select[id='submission_committee_members_attributes_1_committee_role_id']").disabled?).to eq false
        expect{ find("label[for='submission_committee_members_attributes_1_Is voting on approval']") }.not_to raise_error
        within("select#submission_committee_members_attributes_1_committee_role_id") do
          CommitteeRole.where(degree_type: degree.degree_type).each do |option|
            expect(find("option[value='#{option[:id]}']").text).to eq(option[:name]) unless option[:name] == role.name
            expect{ find("option[value='#{option[:id]}']").text }.to raise_error Capybara::ElementNotFound if option[:name] == role.name
          end
        end
      end
    end
  end
end