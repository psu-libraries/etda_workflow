RSpec.describe 'Step 1: Collecting Program Information status', js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'collecting program information'" do
    before do
      webaccess_authorize_author
    end

    let!(:author) { current_author }
    let!(:admin)  { current_admin }
    let!(:submission) { FactoryBot.create :submission, :collecting_program_information, author: author }

    context "visiting the 'Author Submissions Index Page' page" do
      it 'loads the page' do
        visit author_submissions_path
        expect(page).to have_current_path(author_submissions_path)
        expect(page).to have_content(author.last_name)
        expect(page).to have_link('Accessibility')
      end
    end

    context "visiting the 'Update Committee' page" do
      it "raises a forbidden access error" do
        visit edit_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_root_path)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).not_to have_current_path(edit_author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Committee Members' page" do
      it "raises a forbidden access error" do
        visit "/author/submissions/#{submission.id}/committee_members"
        expect(page).to have_current_path(author_root_path)
        expect(page).not_to have_current_path("author/submissions/#{submission.id}/committee_members")
        # expect(page).to have_content('You are not allowed to visit that page at this time, please contact your administrator')
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'raises a forbidden access error' do
        visit author_submission_program_information_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
        expect(page).not_to have_current_path(author_submission_program_information_path(submission))
      end
    end

    context "visiting the 'Review Committee' page" do
      it "raises a forbidden access error" do
        visit author_submission_committee_members_path(submission)
        # expect(page).to have_content 'You have not completed the required steps to review your committee yet'
        expect(page).to have_current_path(author_root_path)
        expect(page).not_to have_current_path(author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_format_review_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Upload Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_edit_final_submission_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_final_submission_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end
  end
  describe "when I submit the 'Program Information' form" do
    before do
      webaccess_authorize_author
    end
    let(:author) { current_author }

    it "submission status updates to 'collecting committee'" do
      program = FactoryBot.create :program, name: 'Information Sciences and Technology'
      second_program = FactoryBot.create :program, name: 'A different program'
      degree = Degree.create(name: 'Master of Science', degree_type_id: DegreeType.default.id, description: 'My Master degree')

      visit new_author_submission_path
      fill_in 'Title', with: 'A unique test title'
      if !InboundLionPathRecord.active?
        select program.name, from: current_partner.program_label.to_s
        select 'Fall', from: 'Semester Intending to Graduate'
        select Time.zone.now.year.to_s, from: 'Graduation Year'
        select degree.description, from: 'Degree'
      else
        expect(page).to have_select('Academic Plan')
        grad_degree = author.inbound_lion_path_record.academic_plan.degrees_display_collection.first[0]
        select(grad_degree, from: 'Academic Plan')
      end
      find_button('Save Program Information').click
      new_submission = Submission.where(title: 'A unique test title').first
      expect(new_submission.status).to eq 'collecting committee'
      expect(new_submission.program.id).to eq(Program.where(name: 'Information Sciences and Technology').first.id)
      visit "/author/submissions/#{new_submission.id}/edit"
      sleep(3)
      select second_program.name, from: current_partner.program_label.to_s
      second_program_id = Program.where(name: second_program.name).first.id
      find_button('Update Program Information').click
      submission = author.submissions.first.reload
      expect(submission.program.id).to eq(second_program_id)
    end
  end
  describe "author can delete a submission" do
    before do
      webaccess_authorize_author
    end
    let(:author) { current_author }

    it "deletes the submission" do
      FactoryBot.create :submission, :collecting_committee, author: author
      start_count = author.submissions.count
      expect(start_count > 0).to be_truthy
      visit author_root_path
      click_link("delete")
      expect(author.submissions.count).to eq(start_count - 1)
    end
  end
end
