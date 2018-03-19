RSpec.describe "when an admin releases a restricted submission for publication after 2 years", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let!(:submission) { FactoryBot.create :submission, :final_is_restricted, author: author }
  let(:committee) { create_committee(submission) }

  let(:inbound_lion_path_record) { FactoryBot.create :inbound_lion_path_record } if current_partner.graduate?

  before do
    webaccess_authorize_admin
    visit root_path
  end
  describe 'it should not update the number of released submissions' do
    let(:initial_released_count) { Submission.where(degree: submission.degree).released_for_publication.count }
    let(:initial_restricted_count) { Submission.where(degree: submission.degree).final_is_withheld.count }

    before do
      submission.released_for_publication_at = Time.zone.now.to_date + 2.years
      submission.released_metadata_at = Time.zone.now.to_date
      submission.status = 'released for publication'
      submission.access_level = 'restricted'
    end
    specify "submission status updates to 'released for publication'" do
      expect(Submission.where(degree: submission.degree).released_for_publication.count).to eql(initial_released_count)
      expect(Submission.where(degree: submission.degree).final_is_withheld.count).to eql(initial_restricted_count)
      expect(submission.released_for_publication_at).not_to be_nil
      visit admin_submissions_index_path(DegreeType.default, 'final_withheld')
      sleep(4)
      click_button 'Select Visible'
      sleep(4)
      expect(page).to have_content(I18n.t("#{current_partner.id}.admin_filters.final_withheld.title"), wait: 5)
      click_button 'Release as Open Access', wait: 8
      # expect(page).to have_content "successfully"
      submission.reload
      expect(submission.status).to eq('released for publication')
      expect(submission).to be_open_access
      expect(submission.released_for_publication_at).not_to be_nil
      expect(submission.released_for_publication_at.to_date).to eq Time.zone.today
      visit admin_submissions_dashboard_path(DegreeType.default)
      released_count = page.find('a#released-for-publication .badge').text
      expect(released_count.to_i).to eql(initial_released_count)
      restricted_updated_count = page.find('#final-withheld .badge').text
      expect(restricted_updated_count.to_i).to eql(initial_restricted_count - 1)
    end
  end
end
