RSpec.describe "Unrelease a submission", js: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:submission) { FactoryBot.create(:submission, :released_for_publication) }

  let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }

  before do
    # expect(SolrDataImportService).to receive(:delta_import)
    webaccess_authorize_admin
    visit admin_edit_submission_path(submission)

    fill_in "Title", with: "A Better Title"
    click_button "Withdraw Publication"
  end

  it "Changes the status to unreleased and also saves any updates" do
    expect(submission.legacy_id).to be_blank
    expect(page).to have_current_path(admin_submissions_dashboard_path(degree_type: DegreeType.default))
    expect(page).not_to have_content "A Better Title"

    visit admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_approved')
    expect(page).to have_content "A Better Title"
  end
end

RSpec.describe 'Unrelease a submission with errors', js: true do
  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }
  let!(:bad_submission) { FactoryBot.create(:submission, :released_for_publication) }

  before do
    webaccess_authorize_admin
    bad_submission.program_id = 0
    visit admin_edit_submission_path(bad_submission)
    click_button "Withdraw Publication"
  end

  it 'does not withdraw the publication and report an error' do
    expect(bad_submission.program_id).to be_zero
    expect(bad_submission.status).to eql('released for publication')
    # expect(page).to have_current_path("/admin/submissions/#{bad_submission.id}/edit")
  end
end
RSpec.describe 'Unrelease a legacy submission without missing data', js: true do
  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }
  let(:author_last_name) { legacy_submission.author.last_name }
  let(:author_first_name) { legacy_submission.author.first_name }

  let!(:legacy_submission) { FactoryBot.create(:submission, :released_for_publication_legacy) }

  before do
    webaccess_authorize_admin
    visit admin_edit_submission_path(legacy_submission)
    fill_in "Title", with: "A new title"
    click_button "Withdraw Publication", wait: 5
  end

  it 'withdraws the publication successfully' do
    legacy_submission.reload
    expect(legacy_submission.legacy_id).not_to be_blank
    expect(page).to have_current_path(admin_submissions_dashboard_path(DegreeType.default.slug))
    expect(page).to have_content("Submission for #{author_first_name} #{author_last_name} was successfully un-published")
  end
end
