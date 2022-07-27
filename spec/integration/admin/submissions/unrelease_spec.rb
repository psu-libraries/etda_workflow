RSpec.describe "Unrelease a submission", js: true, honors: true, milsch: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:submission) { FactoryBot.create(:submission, :released_for_publication) }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }

  # let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }

  before do
    stub_request(:post, /localhost:3000\/solr\/update\?wt=json/)
      .with(
        body: "{\"delete\":1}",
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v2.3.0'
        }
      )
      .to_return(status: 200, body: { error: false }.to_json, headers: {})

    FileUtilityHelper.new.copy_test_file(Rails.root.join(final_submission_file.current_location))
    oidc_authorize_admin
    visit admin_edit_submission_path(submission)
    fill_in "Title", with: "A Better Title"
  end

  it "Changes the status to unreleased and doesn't save any updates" do
    released_location = Rails.root.join(final_submission_file.current_location)
    click_button "Withdraw Publication"
    submission.reload
    final_submission_file.reload
    expect(submission.legacy_id).to be_blank
    expect(page).to have_current_path(admin_edit_submission_path(submission))
    expect(page).not_to have_content "A Better Title"
    unreleased_location = Rails.root.join(final_submission_file.current_location)
    expect(FileUtilityHelper.new).to be_file_was_moved(released_location, unreleased_location)
    # expect(File.exist? unreleased_location).to be_truthy
    # expect(released_location).not_to eql(unreleased_location)
    # expect(File.exist? released_location).to be_falsey
    FileUtilityHelper.new.remove_test_file(unreleased_location)
    # FileUtils.remove_file(unreleased_location, true)
    visit admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_approved')
    expect(page).to have_content submission.title.to_s
  end
end

RSpec.describe 'Unrelease a submission with Solr error', js: true, honors: true, milsch: true do
  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }
  let!(:bad_submission) { FactoryBot.create(:submission, :released_for_publication) }

  before do
    allow_any_instance_of(SolrDataImportService).to receive(:remove_submission).and_raise Errno::ECONNREFUSED
    oidc_authorize_admin
    visit admin_edit_submission_path(bad_submission)
    click_button "Withdraw Publication"
  end

  it 'does not withdraw the publication and report an error' do
    bad_submission.reload
    expect(bad_submission.status).to eql('released for publication')
    expect(page).to have_current_path(admin_edit_submission_path(bad_submission))
    expect(page).to have_content 'A Solr error occurred!'
  end
end

RSpec.describe 'Unrelease a legacy submission without missing data', js: true, honors: true, milsch: true do
  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }
  let(:author_last_name) { legacy_submission.author.last_name }
  let(:author_first_name) { legacy_submission.author.first_name }

  let!(:legacy_submission) { FactoryBot.create(:submission, :released_for_publication_legacy) }

  before do
    stub_request(:post, /localhost:3000\/solr\/update\?wt=json/)
      .with(
        body: "{\"delete\":1}",
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v2.3.0'
        }
      )
      .to_return(status: 200, body: { error: false }.to_json, headers: {})

    oidc_authorize_admin
    visit admin_edit_submission_path(legacy_submission)
    fill_in "Title", with: "A new title"
  end

  it 'withdraws the publication successfully' do
    click_button "Withdraw Publication"
    # expect(page).to have_content("Submission for #{author_first_name} #{author_last_name} was successfully un-published")

    legacy_submission.reload
    expect(legacy_submission.legacy_id).not_to be_blank
    expect(page).to have_current_path(admin_edit_submission_path(legacy_submission))
  end
end
