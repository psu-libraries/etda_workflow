RSpec.describe 'The standard committee form for authors', js: true do
  require 'integration/integration_spec_helper'

  let(:author) { current_author }

  if current_partner.graduate?
    let(:submission) { FactoryBot.create :submission, :collecting_committee, author: author, degree: degree }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.find_by(slug: 'master_thesis') }
    let!(:head_role) { CommitteeRole.find_by(degree_type: degree.degree_type, name: 'Program Head/Chair') }
    let!(:head_member) do
      FactoryBot.create(:committee_member, committee_role: head_role, is_required: true,
                                           is_voting: false, name: 'Test Tester', email: 'abc123@psu.edu',
                                           lionpath_updated_at: DateTime.now, submission_id: submission.id)
    end
  else
    let(:submission) { FactoryBot.create :submission, :collecting_committee, author: author }
  end

  before do
    webaccess_authorize_author
    visit new_author_submission_committee_members_path(submission)
  end

  describe "submit empty form" do
    it "displays validation errors" do
      click_button 'Save and Continue Editing'
      expect(page).to have_content("can't be blank")
      click_button "Save and Continue Submission"
      expect(page).to have_content("can't be blank")
    end
  end

  describe "Cancel" do
    it "does not save the committee" do
      expect(page).to have_content('Add Committee')
      submission.required_committee_roles.count.times do |i|
        i += 1 if current_partner.graduate?
        fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
        fill_in "submission_committee_members_attributes_#{i}_email", with: "buck@hotmail.com"
      end
      click_link('Cancel')
      expect(page).to have_content('My Submissions')
      submission.reload
    end
  end

  describe "save and continue submission" do
    it "saves the committee", honors: true, milsch: true do
      expect(page).to have_link('Add Committee Member')
      if current_partner.graduate?
        expect(page).to have_content('Program Head/Chair')
        expect(find('#submission_committee_members_attributes_0_name').value).to eq('Test Tester')
        expect(find('#submission_committee_members_attributes_0_name').disabled?).to eq true
      end
      # visit new_author_submission_committee_members_path(submission)
      @email_list = [head_member.email] if current_partner.graduate?
      @email_list = [] unless current_partner.graduate?
      submission.required_committee_roles.count.times do |i|
        i += 1 if current_partner.graduate?
        fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
        page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'buck@hotmail.com'")
        @email_list << "buck@hotmail.com"
      end
      click_button 'Save and Continue Submission'
      expect(page).to have_content('My Submissions')
      submission.reload
      assert_equal submission.committee_email_list, @email_list
      expect(submission.committee_members.count).to eq(submission.required_committee_roles.count) unless current_partner.graduate?
      expect(submission.committee_members.count).to eq(submission.required_committee_roles.count + 1) if current_partner.graduate?
      expect(submission.committee_members.first.access_id).to eq('pbm123') unless current_partner.graduate?
      expect(submission.committee_members.second.access_id).to eq('pbm123') if current_partner.graduate?
      visit author_submission_committee_members_path(submission)
      submission.required_committee_roles.count.times do |i|
        i += 1 if current_partner.graduate?
        # expect(page).to have_content role.name
        name = "Professor Buck Murphy #{i}"
        email = "buck@hotmail.com"
        expect(page).to have_content(name)
        expect(page).to have_content(email)
      end
    end
  end

  describe "filling in committee members", js: true, honors: true, milsch: true do
    before do
      @email_list = []
      submission.required_committee_roles.count.times do |i|
        i += 1 if current_partner.graduate?

        fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
        page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'buck@hotmail.com'")
        @email_list << "buck@hotmail.com"
      end
      click_button 'Save and Continue Editing'
    end

    it 'allows an additional committee member to be added', js: true do
      # expect(page).to have_content('successfully')
      expect(page).to have_link('Add Committee Member')
      assert_equal submission.committee_email_list, @email_list unless current_partner.graduate?
      click_link 'Add Committee Member'
      expect(page).to have_link('[ Remove Committee Member ]')
      fields_for_last_committee_member = all('form.edit_submission div.nested-fields').last
      last_role = submission.required_committee_roles.last.name
      within fields_for_last_committee_member do
        expect { select 'Program Head/Chair', from: 'Committee role' }.to raise_error Capybara::ElementNotFound if current_partner.graduate?
        select last_role, from: 'Committee role'
        fill_in "Name", with: "Extra Member"
        fill_in "Email", with: "extra_member@example.com"
      end
      expect { click_button 'Save and Continue Editing' }.to change { submission.committee_members.count }.by 1
      submission.reload
      expect(submission.status).to eq 'collecting format review files'
      expect(submission.committee_provided_at).not_to be_nil
      expect(submission.committee_members.last.is_voting).to eq(true)
      # expect(page).to have_content('successfully')
    end

    it 'sets is_voting to false for special signatory' do
      skip 'Graduate Only' unless current_partner.graduate?

      click_link 'Add Committee Member'
      fields_for_last_committee_member = all('form.edit_submission div.nested-fields').last
      within fields_for_last_committee_member do
        select "Special Signatory", from: 'Committee role'
        fill_in "Name", with: "Extra Member"
        fill_in "Email", with: "extra_member@example.com"
      end
      click_button 'Save and Continue Editing'
      submission.reload
      expect(submission.committee_members.last.is_voting).to eq(false)
    end
  end

  describe "Remove an optional committee member", js: true do
    before do
      submission.committee_members = []
      submission.status = 'collecting format review files'
      roles = CommitteeRole.where(degree_type_id: submission.degree.degree_type.id)
      submission.required_committee_roles.count.times do |i|
        submission.committee_members << FactoryBot.create(:committee_member, name: "Professor Buck Murphy #{i}", email: "buck@hotmail.com", is_required: true, committee_role_id: roles[i].id)
      end
      submission.committee_members << FactoryBot.create(:committee_member, name: 'I am Special', email: 'special@person.com', is_required: false, committee_role_id: CommitteeRole.where(name: 'Special Signatory').first.id)
      submission.save!
      visit edit_author_submission_committee_members_path(submission)
    end

    it "can delete an optional committee member" do
      expect(page).to have_field('Name', with: 'I am Special')
      click_link "Remove Committee Member"
      click_button 'Save and Continue Editing'
      # expect(page).to have_content('successfully')
      submission.reload
      # expect(page).to have_content('Committee updated successfully')
      expect(page).not_to have_field('Name', with: 'I am Special')
    end
    # specify "submission status updates to 'collecting format review files'" do
    #   submission.reload
    #   expect(submission.committee_members.count).to eq submission.required_committee_roles.count
    # end
  end

  describe "typing in part of a known committee member's name", :ldap do
    let(:dropdown_items) { page.all("ul.ui-autocomplete li") }

    let(:dropdown_item_for_alex) do
      dropdown_items.find { |option| option.text =~ /Alex James Kiessling/ }
    end

    before do
      (1..submission.required_committee_roles.count - 1).each do |i|
        fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
        page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'buck@hotmail.com'")
      end
      # Send individual characters one at a time to trigger autocomplete
      # Ref: https://github.com/teampoltergeist/poltergeist/issues/439#issuecomment-66871147
      find("#submission_committee_members_attributes_1_name").native.send_keys(*"alex".chars)
    end

    it "allows me to autocomplete that committee member's information from LDAP" do
      dropdown_item_for_alex.click
      click_button 'Save and Input Program Head/Chair' if current_partner.graduate?
      click_button 'Save and Continue Editing' unless current_partner.graduate?
      visit author_submission_committee_members_path(submission)
      expect(page).to have_content "ajk5603@psu.edu"
    end
  end

  describe 'tooltips', honors: true, milsch: true do
    let!(:committee) { create_committee(submission) }

    it 'has tooltip for required committee members' do
      tooltips = find_all('.fa-exclamation-circle')
      expect(tooltips.count).to eq(submission.required_committee_roles.count + 1) if current_partner.graduate?
      expect(tooltips.count).to eq(submission.required_committee_roles.count) unless current_partner.graduate?
      tooltips.first.hover
      expect(page).to have_css('.tooltip')
    end

    it 'has tooltip for added committee members' do
      click_on 'Add Committee Member'
      sleep 1
      within '#add_member' do
        find('.fa-exclamation-circle').hover
        expect(page).to have_css('.tooltip')
      end
    end
  end

  describe 'email form checkbox' do
    let!(:committee) { create_committee(submission) }

    it 'toggles email form box readonly/writable', milsch: true do
      skip 'Non honors' if current_partner.honors?

      checkboxes = find_all('#email_form_release_switch')
      expect(page).to have_xpath("//input[@id='submission_committee_members_attributes_0_email' and @readonly='readonly']") if current_partner.milsch?
      expect(page).to have_xpath("//input[@id='submission_committee_members_attributes_1_email' and @readonly='readonly']") if current_partner.graduate?
      checkboxes.first.click
      expect(page).to have_xpath("//input[@id='submission_committee_members_attributes_0_email']") if current_partner.milsch?
      expect(page).not_to have_xpath("//input[@id='submission_committee_members_attributes_0_email' and @readonly='readonly']") if current_partner.milsch?
      expect(page).to have_xpath("//input[@id='submission_committee_members_attributes_1_email']") if current_partner.graduate?
      expect(page).not_to have_xpath("//input[@id='submission_committee_members_attributes_1_email' and @readonly='readonly']") if current_partner.graduate?
    end
  end
end
