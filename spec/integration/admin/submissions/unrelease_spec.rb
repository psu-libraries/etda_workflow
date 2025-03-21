RSpec.describe "Unrelease a submission", type: :integration, js: true, honors: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:submission) { FactoryBot.create(:submission, :released_for_publication, public_id: 'publicid') }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: }

  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }

  before do
    stub_request(:post, /localhost:3000\/solr\/update\?wt=json/)
      .with(
        body: "{\"delete\":\"publicid\"}",
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v2.12.2'
        }
      )
      .to_return(status: 200, body: { error: false }.to_json, headers: {})
    stub_request(:post, /localhost:3000\/solr\/update\?wt=json/)
      .with(
        body: "{\"commit\":{}}",
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v2.12.2'
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
    FileUtilityHelper.new.remove_test_file(unreleased_location)
    visit admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_approved')
    expect(page).to have_content submission.title.to_s
  end
end

RSpec.describe 'Unrelease a submission with Solr error', js: true, honors: true do
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

  it 'withdraws the publication and reports an error' do
    bad_submission.reload
    expect(bad_submission.status).to eql('waiting for publication release')
    expect(page).to have_current_path(admin_edit_submission_path(bad_submission))
    expect(page).to have_content 'A Solr error occurred!'
  end
end

RSpec.describe 'Unrelease a legacy submission without missing data', js: true, honors: true do
  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Thesis of Sisyphus", is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }
  let(:author_last_name) { legacy_submission.author.last_name }
  let(:author_first_name) { legacy_submission.author.first_name }

  let!(:legacy_submission) { FactoryBot.create(:submission, :released_for_publication_legacy, public_id: 'publicid') }

  before do
    stub_request(:post, /localhost:3000\/solr\/update\?wt=json/)
      .with(
        body: "{\"delete\":\"publicid\"}",
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v2.12.2'
        }
      )
      .to_return(status: 200, body: { error: false }.to_json, headers: {})
    stub_request(:post, /localhost:3000\/solr\/update\?wt=json/)
      .with(
        body: "{\"commit\":{}}",
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v2.12.2'
        }
      )
      .to_return(status: 200, body: { error: false }.to_json, headers: {})

    oidc_authorize_admin
    visit admin_edit_submission_path(legacy_submission)
    fill_in "Title", with: "A new title"
  end

  it 'withdraws the publication successfully' do
    click_button "Withdraw Publication"

    legacy_submission.reload
    expect(legacy_submission.legacy_id).not_to be_blank
    expect(page).to have_current_path(admin_edit_submission_path(legacy_submission))
  end
end
