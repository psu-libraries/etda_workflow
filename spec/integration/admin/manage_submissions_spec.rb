RSpec.describe "Manage Submissions", js: true do
  require 'integration/integration_spec_helper'

  let!(:admin) { FactoryBot.create :author }
  let!(:degree) { FactoryBot.create :degree }
  let!(:author1) { FactoryBot.create :author }
  let!(:author2) { FactoryBot.create :author }
  let!(:submission1) { FactoryBot.create :submission, :waiting_for_publication_release, author: author1 }
  let!(:submission2) { FactoryBot.create :submission, :waiting_for_publication_release, author: author2 }

  outbound_active = Rails.application.config_for(:lion_path)[current_partner.id.to_s][:lion_path_outbound]

  before do
    webaccess_authorize_admin
    visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
  end

  describe 'Admin Delete submissions' do
    context 'bulk deletes submissions' do
      it 'deletes the submissions and creates outbound lion path records' do
        FactoryBot.create :submission, :waiting_for_publication_release, author: author1
        expect(page).to have_content('Final Submission to be Released')
        expect(page).to have_content('Showing')
        # expect(page).to have_link('Contact Support')
        # expect(page).to have_link('Accessibility')
        outbound_records = OutboundLionPathRecord.all.count
        submission_count = Submission.all.count
        click_button 'Select Visible'
        sleep(3)
        expect(page).to have_button('Delete selected')
        click_button('Delete selected')
        sleep 4
        expect(page).to have_content('successfully')
        total_outbound = OutboundLionPathRecord.all.count
        total_submissions = Submission.all.count
        expect(total_outbound).to eql(outbound_records + 2) if outbound_active
        expect(total_submissions).to eql(submission_count - 2)
      end
    end

    context 'delete one submission' do
      it 'deletes one submission and creates one outbound lion path record' do
        outbound_records = OutboundLionPathRecord.all.count
        submission_count = Submission.all.count
        find(:css, "input.row-checkbox", match: :first).set(true)
        expect(page).to have_button('Delete selected')
        click_button('Delete selected')
        sleep 3
        expect(page).to have_content('successfully')
        total_outbound = OutboundLionPathRecord.all.count
        total_submissions = Submission.all.count
        expect(total_outbound).to eql(outbound_records + 1) if outbound_active
        expect(total_submissions).to eql(submission_count - 1)
      end
    end
  end

  describe 'Admins cannot bulk delete published submissions', js: true do
    let!(:submission3) { FactoryBot.create :submission, :final_is_restricted_to_institution, author: author1, access_level: 'restricted_to_institution' } if current_partner.graduate?
    let!(:submission4) { FactoryBot.create :submission, :final_is_restricted, author: author2 }
    let!(:submission5) { FactoryBot.create :submission, :released_for_publication, author: author1 }

    before do
      webaccess_authorize_admin
    end

    if current_partner.graduate?
      context 'Restricted to institution' do
        before do
          visit admin_submissions_index_path(DegreeType.default, 'final_restricted_institution')
          sleep 5
        end

        it 'does not have a delete button but does have other bulk actions' do
          expect(page).to have_content('Restricted to Penn State')
          expect(page).to have_content('Showing')
          click_button 'Select Visible'
          expect(page).to have_content('Bulk Actions')
          expect(page).to have_xpath("//input[@type='checkbox']")
          expect(page).not_to have_button('Delete Selected')
          expect(page).to have_button('Release as Open Access')
        end
      end

    end
    context 'Withheld' do
      before do
        visit admin_submissions_index_path(DegreeType.default, 'final_withheld')
        sleep 5
      end

      it 'does not have a delete button but has other bulk actions' do
        expect(page).to have_content('Restricted Theses')
        expect(page).to have_content('Showing')
        click_button 'Select Visible'
        sleep(5)
        expect(page).to have_content('Bulk Actions')
        expect(page).to have_xpath("//input[@type='checkbox']")
        expect(page).to have_button('Release as Open Access')
        expect(page).not_to have_button('Delete Selected')
      end
    end

    context 'Released' do
      before do
        visit admin_submissions_index_path(DegreeType.default, 'released_for_publication')
      end

      it 'does not have bulk buttons when nothing is selected' do
        expect(page).to have_content('Released Theses')
        expect(page).to have_content('Showing')
        expect(page).not_to have_content('Bulk Actions')
        expect(page).not_to have_button('Select Visible')
        expect(page).not_to have_button('Release as Open Access')
        expect(page).not_to have_button('Delete Selected')
        expect(page).not_to have_xpath("//input[@type='checkbox']")
      end
    end
  end
end
