RSpec.describe 'The new committee form when Lion Path is active', js: true do
  require 'integration/integration_spec_helper'

  let(:author) { current_author }
  let!(:submission) { FactoryBot.create :submission, :collecting_committee, author: author, lion_path_degree_code: LionPath::MockLionPathRecord.first_degree_code }
  let(:inbound_lion_path_record) { FactoryBot.create :inbound_lion_path_record, author: author }

  # let(:committee) { FactoryBot.create_committee(submission) }

  if InboundLionPathRecord.active?
    before do
      webaccess_authorize_author
      author.inbound_lion_path_record.current_data[:employee_id] = submission.author.psu_idn.to_s
      visit root_path
    end
    describe "When status is 'collecting committee'" do
      context 'graduate student Committee Members from Lion Path are displayed' do
        it "allows graduate students to 'Verify committee'" do
          expect(submission.committee_provided_at).to be_nil
          visit new_author_submission_committee_members_path(submission)
          expect(page).to have_content('Committee')
          verify_button = 'Add Committee'
          verify_button = 'Verify Committee' if submission.using_lionpath?
          expect(page).to have_button verify_button
          expect(page).to have_field('Email', with: submission.academic_plan.committee_member(0)[LionPath::LpKeys::EMAIL])
          expect(page).to have_field('Name', with: "#{submission.academic_plan.committee_member(0)[:first_name]} #{submission.academic_plan.committee_member(0)[:last_name]}")
          @email_list = []
          submission.academic_plan.committee.each do |cm|
            @email_list << cm[LionPath::LpKeys::EMAIL]
          end
          click_button(verify_button)
          expect(page).to have_content('successfully')
          expect(page).to have_current_path(author_root_path)
          submission.reload
          expect(submission.status).to eq 'collecting format review files'
          expect(submission.committee_provided_at).not_to be_nil
          assert_equal submission.committee_email_list.count, submission.committee_members.count
          assert_equal submission.committee_email_list, @email_list
        end
        it "allows graduate students Cancel without saving the committee" do
          expect(submission.committee_members.count).to eq(0)

          verify_button = "Verify Committee"
          expect(page).to have_button verify_button
          expect(page).to have_link('Cancel')
          expect(page).to have_field('Email', with: submission.academic_plan.committee_member(0)[LionPath::LpKeys::EMAIL])
          expect(page).to have_field('Name', with: "#{submission.academic_plan.committee_member(0)[:first_name]} #{submission.academic_plan.committee_member(0)[:last_name]}")
          click_link('Cancel')
          expect(page).not_to have_content('successfully')
          submission.reload
          expect(submission.status).to eq 'collecting committee'
          expect(submission.committee_provided_at).to be_nil
          assert_equal submission.committee_members.count, 0
          expect(page).to have_content('My Submissions')
        end
      end
    end
  end
end
