RSpec.describe 'Approver approval page', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, created_at: Time.zone.now }
  let(:submission1) { FactoryBot.create :submission, :waiting_for_final_submission_response, created_at: Time.zone.now }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }
  let(:approval_configuration) { FactoryBot.create :approval_configuration }
  let(:committee_role) { FactoryBot.create :committee_role, name: "Dissertation Advisor" }
  let(:committee_role_not_advisor) { FactoryBot.create :committee_role, name: "Just Normal Member" }

  before do
    submission.final_submission_files << final_submission_file
    submission.degree.degree_type.approval_configuration = approval_configuration
    webaccess_authorize_approver
  end

  context 'approver matches committee member access_id' do
    before do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      visit "approver/committee_member/#{committee_member.id}"
    end

    let(:committee_member) { FactoryBot.create :committee_member, committee_role: committee_role, submission: submission, access_id: 'approverflow' }

    it 'has link to contact us' do
      expect(page).to have_content('Contact Us')
    end

    it 'can view approval page' do
      expect(page).to have_content('Submission Details')
    end

    it 'can see access level' do
      expect(page).to have_content('Open Access')
    end

    it 'can see other committee members reviews' do
      expect(page).to have_content('Committee Reviews')
    end

    it 'can download final file submission' do
      num_windows = page.driver.browser.window_handles.count
      within("div#file_links") do
        final_link = page.find("a")
        final_link.trigger('click')
        sleep(3)
      end
      expect(page.driver.browser.window_handles.count).to eql(num_windows + 1)
    end

    it 'can edit status and notes' do
      allow(CommitteeMember).to receive(:head_of_program).with(submission.id).and_return(FactoryBot.create(:committee_member))
      within("form#edit_committee_member_#{committee_member.id}") do
        find(:css, "#committee_member_status_approved").set true
        fill_in "committee_member_notes", with: 'Some notes.'
      end
      click_button 'Submit Review'
      sleep 3
      expect(page).to have_current_path(approver_root_path)
      expect(CommitteeMember.find(committee_member.id).status).to eq 'approved'
      expect(CommitteeMember.find(committee_member.id).notes).to eq 'Some notes.'
    end

    context 'approver is advisor and part of graduate school' do
      it 'asks about federal funding used' do
        expect(page).to have_content('Were Federal Funds utilized for this submission?') if current_partner.graduate?
      end
    end

    context 'approver is not advisor' do
      it 'asks about federal funding used' do
        committee_member = FactoryBot.create :committee_member, committee_role: committee_role_not_advisor, submission: submission, access_id: 'testuser'

        visit "approver/committee_member/#{committee_member.id}"
        expect(page).not_to have_content('Were Federal Funds utilized for this submission?')
      end
    end

    context 'approval is complete' do
      xit 'displays the committee members response' do
        committee_member = FactoryBot.create :committee_member, committee_role: committee_role, submission: submission1, access_id: 'testuser'
        visit "approver/committee_member/#{committee_member.id}"

        expect(page).to have_content('approved')
        expect(page).to have_content('Review Completed on')
      end
    end
  end

  context 'approver does not match committee_member access_id' do
    it 'redirects to 401 error page when targeting review page' do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      committee_member = FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/committee_member/#{committee_member.id}"
      expect(page).to have_current_path('/401')
    end

    it 'redirects to 401 error page when targeting submission download' do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/files/final_submissions/#{final_submission_file.id}"
      expect(page).to have_current_path('/401')
    end
  end

  context 'approver is not in Ldap' do
    it 'redirects to 401 error page' do
      committee_member = FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/committee_member/#{committee_member.id}"
      expect(page).to have_current_path('/401')
    end
  end

  context 'access level help text' do
    before do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
    end

    let(:committee_member) { FactoryBot.create :committee_member, committee_role: committee_role, submission: submission, access_id: 'approverflow' }

    context 'submission is open access' do
      it "doesn't display help text" do
        submission.update_attribute :access_level, 'open_access'
        visit "approver/committee_member/#{committee_member.id}"

        expect(page).not_to have_content("Notice: This submission is Restricted")
      end
    end

    context 'submission is restricted' do
      it "does display help text" do
        submission.update_attribute :access_level, 'restricted'
        visit "approver/committee_member/#{committee_member.id}"

        expect(page).to have_content("Notice: This submission is Restricted")
      end
    end

    context 'submission is restricted_to_institution' do
      it "does display help text" do
        submission.update_attribute :access_level, 'restricted_to_institution'
        visit "approver/committee_member/#{committee_member.id}"

        expect(page).to have_content("Notice: This submission is Restricted")
      end
    end
  end
end
