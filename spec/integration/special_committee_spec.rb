RSpec.describe 'Special committee page', type: :integration do
  require 'integration/integration_spec_helper'

  let!(:submission) do
    FactoryBot.create :submission, :waiting_for_committee_review, final_submission_files_uploaded_at: DateTime.now,
                                                                  final_submission_approved_at: DateTime.now, author: (create :author)
  end
  let!(:committee_member) do
    FactoryBot.create :committee_member, status: '', email: 'approverflow@gmail.com',
                                         approval_started_at: DateTime.now, committee_role: (create :committee_role)
  end
  let!(:committee_member_token) do
    FactoryBot.create :committee_member_token, authentication_token: '1'
  end

  before do
    committee_member.committee_member_token = committee_member_token
    committee_member.save!
    submission.committee_members << committee_member
    submission.save!
  end

  context 'when not logged in as an approver' do
    it 'displays content' do
      visit '/special_committee/1'
      expect(page).to have_content('New to Penn State?')
      expect(page).to have_link('Create Your Penn State Account', href: 'https://accounts.psu.edu/create/new')
      expect(page).to have_content('Already have or created a Penn State OneID account?')
      expect(page).to have_button('Proceed to ETD My Reviews Page')
    end

    it 'marries an approver and multiple committee member records via token when clicking advance button', :js do
      committee_member_two = FactoryBot.create(:committee_member, submission:, status: '', email: 'approverflow@gmail.com')
      committee_member_token_two = FactoryBot.create :committee_member_token, authentication_token: '2'
      committee_member_two.committee_member_token = nil
      committee_member_two.committee_member_token = committee_member_token_two
      visit '/special_committee/1'
      allow_any_instance_of(Devise::Strategies::OidcAuthenticatable).to receive(:remote_user).and_return('approverflow')
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      oidc_authorize_approver
      expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 0
      click_button("Proceed to ETD My Reviews Page")
      expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 2
      expect(Approver.find_by(access_id: 'approverflow').committee_members.first.access_id).to eq 'approverflow'
      expect(Approver.find_by(access_id: 'approverflow').committee_members.second.access_id).to eq 'approverflow'
      expect { CommitteeMemberToken.find(committee_member_token.id) }.to raise_error ActiveRecord::RecordNotFound
      expect { CommitteeMemberToken.find(committee_member_token_two.id) }.to raise_error ActiveRecord::RecordNotFound
      expect(page).to have_current_path(approver_approver_reviews_path)
      expect(page).to have_link(submission.title)
    end

    it 'does not marry an approver and committee member record via token when clicking advance button', :js do
      visit '/special_committee/1'
      click_button("Proceed to ETD My Reviews Page")
      expect { Approver.find_by(access_id: 'approverflow').committee_members.count }.to raise_error NoMethodError
      expect(CommitteeMemberToken.find(committee_member_token.id)).to eq committee_member_token
    end

    it 'marries an approver and committee member record via token when clicking advance button', :js do
      visit '/special_committee/1'
      allow_any_instance_of(Devise::Strategies::OidcAuthenticatable).to receive(:remote_user).and_return('approverflow')
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      oidc_authorize_approver
      expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 0
      click_button("Proceed to ETD My Reviews Page")
      expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 1
      expect(Approver.find_by(access_id: 'approverflow').committee_members.first.access_id).to eq 'approverflow'
      expect { CommitteeMemberToken.find(committee_member_token.id) }.to raise_error ActiveRecord::RecordNotFound
      expect(page).to have_current_path(approver_approver_reviews_path)
      expect(page).to have_link(submission.title)
    end
  end

  context 'when logged in as an approver' do
    before do
      allow_any_instance_of(Devise::Strategies::OidcAuthenticatable).to receive(:remote_user).and_return('approverflow')
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      oidc_authorize_approver
    end

    it 'automatically proceeds to reviews if signed into oidc but does not marry committee record' do
      visit '/special_committee/X'
      expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 0
      expect(page).to have_current_path(approver_approver_reviews_path)
    end

    it 'automatically proceeds to reviews if signed into oidc and marries committee record if exists' do
      visit '/special_committee/1'
      expect(Approver.find_by(access_id: 'approverflow').committee_members.count).to eq 1
      expect(page).to have_current_path(approver_approver_reviews_path)
    end
  end
end
