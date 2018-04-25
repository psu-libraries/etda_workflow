RSpec.describe "when an admin releases the submission for publication", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, author: author }
  let(:committee) { create_committee(submission) }
  let(:inbound_lion_path_record) { FactoryBot.create :inbound_lion_path_record }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }

  before do
    webaccess_authorize_admin
    visit root_path
    FileUtilityHelper.new.copy_test_file(Rails.root.join(final_submission_file.current_location))
  end

  context 'it updates the number of released submissions', js: true do
    let(:initial_released_count) { Submission.where(degree: DegreeType.default).released_for_publication.count }

    it "submission status updates to 'released for publication'" do
      unreleased_location = Rails.root.join(final_submission_file.current_location)
      expect(File).to be_exist(unreleased_location)
      expect(Submission.where(degree: DegreeType.default).released_for_publication.count).to eq(initial_released_count)
      expect(submission.released_for_publication_at).to be_nil
      visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
      sleep(3)
      click_button 'Select Visible'
      expect(page).to have_content('Showing', wait: 5)
      page.find('h1', text: 'Final Submission to be Released', wait: 8)
      # select "#{Time.zone.now.year}", from: 'selected_date[year]'
      # select 'December', from: 'selected_date[month]'
      # select '30', from: 'selected_date[day]'
      sleep(8)
      page.find('#selected_date_year').select(Time.zone.now.year.to_s)
      page.find('#selected_date_month').select('December')
      page.find('#selected_date_day').select("30")
      expect(page).to have_button 'Release selected for publication'
      page.accept_confirm do
        click_button 'Release selected for publication'
      end
      # expect(page).to have_content "successfully"
      submission.reload
      released_location = Rails.root.join(final_submission_file.current_location)
      expect(FileUtilityHelper.new).to be_file_was_moved(unreleased_location, released_location)
      # expect(File).to be_exist(released_location)
      # expect(released_location).not_to eql(unreleased_location)
      # expect(File).not_to be_exist(unreleased_location)
      expect(submission.status).to eq 'released for publication'
      expect(submission.released_for_publication_at).not_to be_nil
      expect(submission.released_for_publication_at.strftime('%Y %m %d')).to eq "#{Time.zone.now.year} 12 30"
      expect(submission.released_metadata_at).to eq submission.released_for_publication_at
      visit admin_submissions_dashboard_path(DegreeType.default)
      sleep(3)
      released_count = page.find('a#released-for-publication .badge').text
      expect(released_count.to_i).to eql(initial_released_count + 1)
      FileUtilityHelper.new.remove_test_file(released_location)
    end
  end
end
