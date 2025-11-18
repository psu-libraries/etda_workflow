RSpec.describe "Committee Member Dashboard", :js, type: :integration do
  require 'integration/integration_spec_helper'
  let!(:committee_member1) { FactoryBot.create :committee_member, faculty_member_id: faculty_member1.id, submission_id: submission1.id }
  let!(:faculty_member1) { FactoryBot.create :faculty_member, department: "IST", college: "College of IST" }
  let!(:submission1) { FactoryBot.create :submission, program_id: program1.id }
  let!(:program1) { FactoryBot.create :program, name: "Data Science" }

  # different department, but the same program
  let!(:committee_member2) { FactoryBot.create :committee_member, faculty_member_id: faculty_member2.id, submission_id: submission2.id }
  let!(:faculty_member2) { FactoryBot.create :faculty_member, webaccess_id: "abc234", department: "SRA", college: "College of IST" }
  let!(:submission2) { FactoryBot.create :submission, program_id: program1.id }

  # same department, but different program
  let!(:committee_member3) { FactoryBot.create :committee_member, faculty_member_id: faculty_member3.id, submission_id: submission3.id }
  let!(:faculty_member3) { FactoryBot.create :faculty_member, webaccess_id: "abc345", department: "IST", college: "College of IST" }
  let!(:submission3) { FactoryBot.create :submission, program_id: program3.id }
  let!(:program3) { FactoryBot.create :program, name: "Computer Science" }

  # different department and a different program
  let!(:committee_member4) { FactoryBot.create :committee_member, faculty_member_id: faculty_member4.id, submission_id: submission4.id }
  let!(:faculty_member4) { FactoryBot.create :faculty_member, webaccess_id: "abc222", department: "HCDD", college: "College of IST" }
  let!(:submission4) { FactoryBot.create :submission, program_id: program4.id }
  let!(:program4) { FactoryBot.create :program, name: "Food Science" }

  # same faculty member
  let!(:committee_member5) { FactoryBot.create :committee_member, faculty_member_id: faculty_member1.id, submission_id: submission5.id }
  let!(:submission5) { FactoryBot.create :submission, program_id: program5.id }
  let!(:program5) { FactoryBot.create :program, name: "Science" }

  # different college, deparment, and program
  let!(:committee_member6) { FactoryBot.create :committee_member, faculty_member_id: faculty_member6.id, submission_id: submission6.id }
  let!(:faculty_member6) { FactoryBot.create :faculty_member, webaccess_id: "xyz987", department: "Industrial Engineering", college: "College of Engineering" }
  let!(:submission6) { FactoryBot.create :submission, program_id: program6.id }
  let!(:program6) { FactoryBot.create :program, name: "Statistics" }

  before do
    path = root_path + "committee_member_dashboard"
    visit path
  end

  describe "Visit committee member dashboard" do
    it "displays the top college of the drop down (Engineering)" do
      expect(page).to have_content("Industrial Engineering")
      expect(page).not_to have_content("HCDD")
    end
  end

  describe "Select Committee Member College" do
    before do
      select('College of IST', from: 'college-select')
    end

    it "displays departments in selected college" do
      expect(page).to have_text("This graph displays")
      expect(page).to have_text("The chart reflects College of IST faculty data.")
      expect(page).to have_text("Total Committee Members:")
      expect(page).to have_content("Food Science") # Program
      expect(page).to have_content("HCDD") # department
      expect(page).not_to have_content("Industrial Engineering")
    end

    describe "Visit Facult Department" do
      before do
        page.execute_script "window.scrollBy(0,500)"
        node = find('text.department-text', text: 'IST')
        page.execute_script('arguments[0].scrollIntoView()', node)
        page.evaluate_script("document.getElementsByClassName('department-node')[1].dispatchEvent(new Event('click'))")
        # save_screenshot
      end

      # Before statement doesn't work. Can not click the node to go to the bar chart
      it "Check for associated programs", skip: 'before statement does not work' do
        expect(page).to have_text("Publications for Committee Member Department: IST")
        expect(page).to have_text("Selected Committee Member College: College of IST")
        expect(page).to have_content("Data Science") # Program
        expect(page).not_to have_content("Food Science") # Program
      end

      describe "Test Back Button" do
        before do
          back = find("span.back-button")
          back.click
        end

        # does not go to the bar chart, so the back button is not available
        it "test contents after back button", skip: 'back button not available' do
          expect(page).to have_content("Food Science") # Program
        end
      end
    end

    describe "Visit Student Program" do
      # Before statement doesn't work. Can not click the node to go to the bar chart
      it "Check for associated departments", skip: 'before statement does not work' do
        expect(page).to have_text("Publications for Student Program: Data Science")
        expect(page).to have_content("IST")
      end
    end
  end
end
