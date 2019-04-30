RSpec.describe 'The standard committee form for authors', js: true do
  require 'integration/integration_spec_helper'

  let(:author) { current_author }
  let(:submission) { FactoryBot.create :submission, :collecting_committee, author: author }

  unless InboundLionPathRecord.active?
    before do
      allow(InboundLionPathRecord).to receive(:active?).and_return(false)
      webaccess_authorize_author
      visit root_path
      visit new_author_submission_committee_members_path(submission)
    end

    describe "submit empty form" do
      it "displays validation errors" do
        click_button 'Save and Continue Editing'
        expect(page).to have_content("can't be blank")
      end
    end

    describe "return to author index page" do
      it "returns to the author index page and displays validation errors" do
        expect(submission.committee_members.empty?).to eq(true)
        click_button "Save and Return to Dashboard"
        expect(page).to have_content("can't be blank")
      end
    end

    describe "Cancel" do
      it "does not save the committee" do
        expect(submission.committee_members.empty?).to eq(true)
        expect(page).to have_content('Add Committee')
        submission.required_committee_roles.count.times do |i|
          fill_in "submission_committee_members_attributes_#{i}_name", with: "Name #{i}"
          fill_in "submission_committee_members_attributes_#{i}_email", with: "name_#{i}@example.com"
        end
        click_link('Cancel')
        expect(page).to have_content('My Submissions')
        submission.reload
        expect(submission.committee_members).to be_empty
      end
    end

    describe "save and return to dashboard" do
      it "saves the committee" do
        expect(submission.committee_members.empty?).to eq(true)
        expect(page).to have_link('Add Committee Member')
        # visit new_author_submission_committee_members_path(submission)
        @email_list = []
        submission.required_committee_roles.count.times do |i|
          fill_in "submission_committee_members_attributes_#{i}_name", with: "Name #{i}"
          page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'name_#{i}@psu.edu'");
          @email_list << "name_#{i}@psu.edu"
        end
        click_button('Save and Return to Dashboard')
        sleep(3)
        expect(page).to have_content('My Submissions')
        submission.reload
        assert_equal submission.committee_email_list, @email_list
        expect(submission.committee_members.count).to eq(submission.required_committee_roles.count)
        expect(submission.committee_members.first.access_id).to eq('name_0')
        visit author_submission_committee_members_path(submission)
        submission.required_committee_roles.count.times do |i|
          # expect(page).to have_content role.name
          name = "Name #{i}"
          email = "name_#{i}@psu.edu"
          expect(page).to have_content(name)
          expect(page).to have_content(email)
        end
      end
    end

    describe "filling in committee members", js: true do
      before do
        @email_list = []
        submission.required_committee_roles.count.times do |i|
          fill_in "submission_committee_members_attributes_#{i}_name", with: "Name #{i}"
          page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'name_#{i}@example.com'");
          @email_list << "name_#{i}@example.com"
        end
        click_button 'Save and Continue Editing'
      end

      it 'allows an additional committee member to be added' do
        # expect(page).to have_content('successfully')
        expect(page).to have_link('Add Committee Member')
        assert_equal submission.committee_email_list, @email_list
        click_link 'Add Committee Member'
        expect(page).to have_link('[ Remove Committee Member ]')
        fields_for_last_committee_member = all('form.edit_submission div.nested-fields').last
        last_role = submission.required_committee_roles.last.name
        within fields_for_last_committee_member do
          select last_role, from: 'Committee role'
          fill_in "Name", with: "Extra Member"
          fill_in "Email", with: "extra_member@example.com"
        end
        click_button 'Save and Return to Dashboard'
        # expect(page).to have_content('successfully')
      end

      specify "submission status updates to 'collecting format review files'" do
        submission.reload
        expect(submission.status).to eq 'collecting format review files'
      end
      specify "submission committee_provided_at is set" do
        submission.reload
        expect(submission.committee_provided_at).not_to be_nil
        visit edit_author_submission_committee_members_path(submission)
        expect(page).to have_link('Add Committee Member')
      end
    end

    describe "Remove an optional committee member for honors college authors", js: true do
      before do
        submission.committee_members = []
        submission.status = 'collecting committee'
        roles = CommitteeRole.all
        submission.required_committee_roles.count.times do |i|
          submission.committee_members << FactoryBot.create(:committee_member, name: "Name_#{i}", email: "name_#{i}_@example.com", is_required: false, committee_role_id: roles[i].id)
        end
        submission.committee_members << FactoryBot.create(:committee_member, name: 'I am Special', email: 'special@psu.edu', is_required: false, committee_role_id: CommitteeRole.where(num_required: 0).first.id)
        submission.save!
        visit new_author_submission_committee_members_path(submission)
      end

      let(:last_remove_link) { all(".committee_remove a href").last }

      # PROBLEM FINDING THE RemoveLINK
      xit "can delete an optional committee member" do
        remove_link = all(".committee_remove a href").last
        expect(page).to have_field('Name', with: 'I am Special')
        remove_link.click
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
          fill_in "submission_committee_members_attributes_#{i}_name", with: "Name #{i}"
          fill_in "submission_committee_members_attributes_#{i}_email", with: "email#{i}@psu.edu"
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
end
