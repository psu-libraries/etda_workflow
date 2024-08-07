RSpec.describe 'When Collecting Program Information status', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'collecting program information'" do
    before do
      oidc_authorize_author
    end

    let!(:author) { current_author }
    let!(:admin)  { current_admin }
    let!(:submission) do
      FactoryBot.create :submission,
                        :collecting_program_information,
                        author:,
                        semester: 'Fall'
    end

    it 'provides semester selection help text in graduate and honors' do
      visit "author/submissions/#{submission.id}/edit"

      expect(page).to have_content(I18n.t("#{current_partner.id}.partner.semester_hint")) if current_partner.graduate? || current_partner.honors?
      expect(page).not_to have_content(I18n.t("#{current_partner.id}.partner.semester_hint")) if current_partner.milsch? || current_partner.sset?
    end

    describe "editing program information with imported lionpath data" do
      let!(:program) { FactoryBot.create :program }

      before do
        submission.update program_id: program.id, year: DateTime.now.year,
                          title: nil, semester: 'Fall', lionpath_updated_at: DateTime.now,
                          degree_id: Degree.first.id
      end

      it 'displays imported data and updates when submitted' do
        skip 'graduate only' unless current_partner.graduate?

        visit "author/submissions/#{submission.id}/edit"
        expect(find("input[id='submission_title']").value).to be_empty
        find("input[id='submission_title']").set 'Test Title'
        expect(find("select[id='submission_program_id']").value).to eq program.id.to_s
        expect(find("select[id='submission_program_id']").disabled?).to eq true
        expect(find("select[id='submission_degree_id']").value).to eq Degree.first.id.to_s
        expect(find("select[id='submission_degree_id']").disabled?).to eq true
        expect(find("select[id='submission_semester']").value).to eq 'Fall'
        expect(find("select[id='submission_semester']").disabled?).to eq false
        expect(find("select[id='submission_year']").value).to eq DateTime.now.year.to_s
        expect(find("select[id='submission_year']").disabled?).to eq false
        click_on "Update #{submission.degree_type} Title"
        expect(Submission.find(submission.id).title).to eq 'Test Title'
        expect(Submission.find(submission.id).status).to eq 'collecting committee'
      end
    end

    describe 'when submission is beyond_collecting_committee' do
      let!(:program) { FactoryBot.create :program }

      before do
        submission.update program_id: program.id, year: DateTime.now.year,
                          title: 'Title', semester: 'Fall',
                          degree_id: Degree.first.id, status: 'collecting format review files'
      end

      it "doesn't change status of submission", honors: true do
        visit "author/submissions/#{submission.id}/edit"
        click_on "Update #{submission.degree_type} Title" if current_partner.graduate?
        click_on "Update Program Information" unless current_partner.graduate?
        expect(Submission.find(submission.id).status).to eq 'collecting format review files'
      end
    end
  end

  describe "when I submit the 'Program Information' form" do
    before do
      oidc_authorize_author
    end

    let(:author) { current_author }

    it "submission status updates to 'collecting committee'", honors: true do
      program = FactoryBot.create :program, name: 'Information Sciences and Technology'
      second_program = FactoryBot.create :program, name: 'A different program'
      degree = Degree.create(name: 'Degree Name', degree_type_id: DegreeType.default.id, description: 'My Degree')

      visit new_author_submission_path
      fill_in 'Title', with: 'A unique test title'
      select program.name, from: current_partner.program_label.to_s
      select 'Fall', from: 'Semester Intending to Graduate'
      select Time.zone.now.year.to_s, from: 'Graduation Year'
      select degree.description, from: 'Degree'
      find_button("Save Thesis or Dissertation Title").click if current_partner.graduate?
      find_button('Save Program Information').click unless current_partner.graduate?
      new_submission = author.submissions.first
      expect(new_submission.status).to eq 'collecting committee'
      expect(new_submission.program.id).to eq(Program.where(name: 'Information Sciences and Technology').first.id)
      if current_partner.honors?
        visit "/author/submissions/#{new_submission.id}/edit"
        select second_program.name, from: current_partner.program_label.to_s
        second_program_id = Program.where(name: second_program.name).first.id
        click_on "Update Program Information"
        submission = author.submissions.first.reload
        expect(submission.program.id).to eq(second_program_id)
      end
    end
  end

  describe "when I sign the acknowledgment page" do
    before do
      oidc_authorize_author
    end

    let(:author) { current_author }

    it "page progresses to edit page" do
      skip 'graduate only' unless current_partner.graduate?
      second_program = FactoryBot.create :program, name: 'A different program'
      new_submission = FactoryBot.create(:submission, :collecting_committee, author:, acknowledgment_page_submitted_at: nil)
      visit "/author/submissions/#{new_submission.id}/edit"
      expect(page).to have_content('I acknowledge that')
      fields = all('input[type="text"]')
      fields.each do |field|
        field.set('JLE')
      end
      find_button('Submit').click
      expect(page).to have_content("Update #{new_submission.degree_type} Title")
      select second_program.name, from: current_partner.program_label.to_s
      second_program_id = Program.where(name: second_program.name).first.id
      click_on "Update #{new_submission.degree_type} Title"
      submission = author.submissions.first.reload
      expect(submission.program.id).to eq(second_program_id)
    end
  end

  describe "author can delete a submission", honors: true do
    before do
      oidc_authorize_author
    end

    let(:author) { current_author }

    it "deletes the submission" do
      FactoryBot.create(:submission, :collecting_committee, author:)
      start_count = author.submissions.count
      expect(start_count > 0).to be_truthy
      visit author_root_path
      if current_partner.graduate?
        expect(page).not_to have_link "delete"
      else
        page.accept_confirm do
          click_link("delete")
        end
        sleep 0.1
        expect(author.submissions.count).to eq(start_count - 1)
      end
    end
  end
end
