RSpec.describe 'The standard committee form for authors', js: true do
  require 'integration/integration_spec_helper'

  let(:author) { current_author }
  let(:submission) { FactoryBot.create :submission, :collecting_committee, author: author }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }

  let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: true } if current_partner.graduate?
  let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: false } unless current_partner.graduate?

  unless InboundLionPathRecord.active?
    before do
      allow(InboundLionPathRecord).to receive(:active?).and_return(false)
      webaccess_authorize_author
      visit root_path
      visit new_author_submission_committee_members_path(submission)
    end

    describe "submit empty form" do
      it "displays validation errors" do
        click_button 'Save and Continue Editing' unless current_partner.graduate?
        click_button 'Save and Input Program Head/Chair >>' if current_partner.graduate?
        expect(page).to have_content("can't be blank")
      end
    end

    describe "return to author index page" do
      it "returns to the author index page and displays validation errors" do
        skip 'Non Graduate' if current_partner.graduate?
        expect(submission.committee_members.empty?).to eq(true)
        click_button "Save and Continue Submission"
        expect(page).to have_content("can't be blank")
      end
    end

    describe "Cancel" do
      it "does not save the committee" do
        expect(submission.committee_members.empty?).to eq(true)
        expect(page).to have_content('Add Committee')
        submission.required_committee_roles.count.times do |i|
          next if i == 0 && current_partner.graduate?

          fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
          fill_in "submission_committee_members_attributes_#{i}_email", with: "buck@hotmail.com"
        end
        click_link('Cancel')
        expect(page).to have_content('My Submissions')
        submission.reload
        expect(submission.committee_members).to be_empty
      end
    end

    describe "save and continue submission" do
      it "saves the committee" do
        expect(submission.committee_members.empty?).to eq(true)
        expect(page).to have_link('Add Committee Member')
        # visit new_author_submission_committee_members_path(submission)
        @email_list = []
        submission.required_committee_roles.count.times do |i|
          next if i == 0 && current_partner.graduate?

          fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
          page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'buck@hotmail.com'")
          @email_list << "buck@hotmail.com"
        end
        click_button 'Save and Continue Submission' unless current_partner.graduate?
        click_button 'Save and Input Program Head/Chair >>' if current_partner.graduate?
        sleep(3)
        expect(page).to have_content('My Submissions') unless current_partner.graduate?
        expect(page).to have_content('Input Program Head/Chair') if current_partner.graduate?
        submission.reload
        assert_equal submission.committee_email_list, @email_list
        expect(submission.committee_members.count).to eq(submission.required_committee_roles.count) unless current_partner.graduate?
        expect(submission.committee_members.count).to eq(submission.required_committee_roles.count - 1) if current_partner.graduate?
        expect(submission.committee_members.first.access_id).to eq('pbm123') unless current_partner.graduate?
        expect(submission.committee_members.first.access_id).to eq('pbm123') if current_partner.graduate?
        visit author_submission_committee_members_path(submission)
        submission.required_committee_roles.count.times do |i|
          next if i == 0 && current_partner.graduate?

          # expect(page).to have_content role.name
          name = "Professor Buck Murphy #{i}"
          email = "buck@hotmail.com"
          expect(page).to have_content(name)
          expect(page).to have_content(email)
        end
      end
    end

    describe "filling in committee members", js: true do
      before do
        @email_list = []
        submission.required_committee_roles.count.times do |i|
          next if i == 0 && current_partner.graduate?

          fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
          page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'buck@hotmail.com'")
          @email_list << "buck@hotmail.com"
        end
        click_button 'Save and Continue Editing' unless current_partner.graduate?
      end

      it 'allows an additional committee member to be added' do
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
        expect { click_button 'Save and Input Program Head/Chair >>' }.to change { submission.committee_members.count }.by 6 if current_partner.graduate?
        expect { click_button 'Save and Continue Editing' }.to change { submission.committee_members.count }.by 1 unless current_partner.graduate?
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
        click_button 'Save and Input Program Head/Chair >>' if current_partner.graduate?
        click_button 'Save and Continue Editing' unless current_partner.graduate?
        submission.reload
        expect(submission.committee_members.last.is_voting).to eq(false)
      end
    end

    describe "Remove an optional committee member", js: true do
      before do
        submission.committee_members = []
        submission.status = 'collecting format review files'
        roles = CommitteeRole.all
        submission.required_committee_roles.count.times do |i|
          submission.committee_members << FactoryBot.create(:committee_member, name: "Professor Buck Murphy #{i}", email: "buck@hotmail.com", is_required: true, committee_role_id: roles[i].id)
        end
        submission.committee_members << FactoryBot.create(:committee_member, name: 'I am Special', email: 'special@person.com', is_required: false, committee_role_id: CommitteeRole.where(num_required: 0).first.id)
        submission.save!
        visit edit_author_submission_committee_members_path(submission)
      end

      # PROBLEM FINDING THE RemoveLINK
      it "can delete an optional committee member" do
        expect(page).to have_field('Name', with: 'I am Special')
        click_link "Remove Committee Member"
        sleep(2)
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

    # following works when this data is returned from ldap_lookup controller:
    # results = [
    #     { id: 'saw3@psu.edu', label: 'Steve Wilson', value: 'Steve Wilson' },
    #     { id: 'ajk5603@psu.edu', label: 'Alex Kiessling', value: 'Alex Kiessling' },
    #     { id: 'saw140@psu.edu', label: 'Scott Woods', value: 'Scott Woods' },
    # ]

    describe "typing in part of a known committee member's name", :ldap do
      let(:dropdown_items) { page.all("ul.ui-autocomplete li") }

      let(:dropdown_item_for_joni) do
        dropdown_items.find { |option| option.text =~ /Joni Lee Barnoff/ }
      end

      before do
        (1..submission.required_committee_roles.count - 1).each do |i|
          fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
          fill_in "submission_committee_members_attributes_#{i}_email", with: "pbm#{i}@psu.edu"
        end
        # Send individual characters one at a time to trigger autocomplete
        # Ref: https://github.com/teampoltergeist/poltergeist/issues/439#issuecomment-66871147
        find("#submission_committee_members_attributes_0_name").native.send_keys(*"Barn".chars)
        sleep 3 # Autocomplete delays before sending/displaying results
      end

      it "allows me to autocomplete that committee member's information from LDAP" do
        dropdown_item_for_joni.click
        click_button 'Save and Continue Editing'
        visit author_submission_committee_members_path(submission)
        expect(page).to have_content "xxb13@psu.edu"
      end
    end
  end

  describe 'tooltips' do
    let!(:committee) { create_committee(submission) }

    it 'has tooltip for required committee members' do
      tooltips = find_all('.fa-exclamation-circle')
      expect(tooltips.count).to eq(submission.required_committee_roles.count - 1) if current_partner.graduate?
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

    it 'toggles email form box readonly/writable' do
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
