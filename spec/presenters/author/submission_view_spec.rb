require 'presenters/presenters_spec_helper'

RSpec.describe Author::SubmissionView do
  let(:submission) { FactoryBot.create :submission }
  let(:view) { described_class.new submission }

  describe '#formatted_program_information' do
    let(:program) { FactoryBot.create :program, name: 'Phys Ed.' }
    let(:degree) { FactoryBot.create :degree, name: 'Doctorate' }
    let(:submission) do
      FactoryBot.create :submission, program:,
                                     degree:,
                                     semester: 'Spring',
                                     year: Date.new(2016, 0o6, 0o1).year
    end

    it "returns a formatted name for the submission" do
      expect(view.formatted_program_information).to eq 'Phys Ed. Doctorate - Spring 2016'
    end
  end

  describe '#delete_link' do
    context "when step two is the current step" do
      before { submission.status = 'collecting committee' }

      it "returns a link to delete the submission" do
        expect(view.delete_link).to eq "<span class='delete-link medium'><a href='/author/submissions/#{submission.id}' class='text-danger' data-method='delete' data-confirm='Permanently delete this submission?' rel='nofollow' >[delete submission<span class='sr-only'>submission '#{submission.title}'</span>]</a></span>"
      end
    end

    context "when step three is the current step for the first time" do
      before do
        submission.status = 'collecting format review files'
        submission.format_review_notes = nil
      end

      it "returns a link to delete the submission" do
        expect(view.delete_link).to eq "<span class='delete-link medium'><a href='/author/submissions/#{submission.id}' class='text-danger' data-method='delete' data-confirm='Permanently delete this submission?' rel='nofollow' >[delete submission<span class='sr-only'>submission '#{submission.title}'</span>]</a></span>"
      end
    end

    context 'when the submission is beyond step three' do
      it "returns an empty string" do
        submission.status = 'collecting final submission files'
        expect(view.delete_link).to eq('')
      end
    end

    context 'when step three is the current step after my format review is rejected' do
      before do
        submission.status = 'collecting format review files'
        submission.format_review_notes = 'some format review notes'
      end

      it "returns an empty string" do
        expect(view.delete_link).to eq ''
      end
    end
  end

  describe '#created_on' do
    before do
      submission.created_at = Time.zone.local(2014, 7, 4)
    end

    it 'returns the formatted date' do
      expect(view.created_on).to eq 'July 4, 2014'
    end
  end

  describe 'step_one_class' do
    context "when submission's status is beyond collecting program information" do
      before { submission.status = 'collecting committee' }

      it "returns 'complete'" do
        expect(view.step_one_class).to eq 'complete'
      end
    end
  end

  describe '#step_one_description' do
    context "when step two is the current step" do
      before { submission.status = 'collecting committee' }

      it "returns a link to edit step one" do
        expect(view.step_one_description).to eq "Provide program information <a href='#{edit_author_submission_path(submission)}' class='medium'>[Update Program Information <span class='sr-only'>program information for submission '#{submission.title}'</span>]</a>"
      end
    end

    context "when step three is the current step" do
      before { submission.status = 'collecting format review files' }

      it "returns a link to review step one" do
        expect(view.step_one_description).to eq "Provide program information <a href='/author/submissions/#{submission.id}/program_information' class='medium'>[Review Program Information <span class='sr-only'>program information for submission '#{submission.title}'</span>]</a>"
      end
    end

    context "when the submission is beyond step three" do
      it "returns a link to review step two" do
        submission.status = 'collecting final submission files'
        expect(view.step_one_description).to eq "Provide program information <a href='#{author_submission_program_information_path(submission)}' class='medium'>[Review Program Information <span class='sr-only'>program information for submission '#{submission.title}'</span>]</a>"
      end
    end
  end

  describe 'step_one_status' do
    context "when submission's status is beyond collecting program information and was not imported via lionpath" do
      before do
        submission.status = 'collecting committee'
        submission.created_at = DateTime.strptime('2020-01-01', '%Y-%m-%d')
      end

      it "returns completed partial and text as hash" do
        expect(view.step_one_status).to eq(text: "completed on January 1, 2020", partial_name: '/author/shared/completed_indicator')
      end
    end

    context "when submission's status is beyond collecting program information and was imported via lionpath" do
      before do
        submission.status = 'collecting committee'
        submission.created_at = DateTime.strptime('2020-01-01', '%Y-%m-%d')
        submission.lionpath_updated_at = DateTime.strptime('2020-01-01', '%Y-%m-%d')
      end

      it "returns completed partial and created on text as hash" do
        expect(view.step_one_status).to eq(text: "created on January 1, 2020", partial_name: '/author/shared/completed_indicator')
      end
    end

    context "when submission's status is collecting program information" do
      before do
        submission.status = 'collecting program information'
        submission.created_at = DateTime.strptime('2020-01-01', '%Y-%m-%d')
        submission.lionpath_updated_at = DateTime.strptime('2020-01-01', '%Y-%m-%d')
      end

      it "returns created on text as hash" do
        expect(view.step_one_status).to eq(text: "created on January 1, 2020")
      end
    end
  end

  describe 'step two: committee' do
    describe '#step_two_class' do
      context 'when the submission has no committee' do
        before { submission.status = 'collecting committee' }

        it 'returns "current"' do
          expect(view.step_two_class).to eq 'current'
        end
      end

      context 'when the submission has a committee' do
        it 'returns "complete"' do
          submission.status = 'waiting for format review response'
          expect(view.step_two_class).to eq 'complete'
        end
      end
    end

    describe '#step_two_description' do
      let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
      let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type }

      before do
        submission.degree = degree
      end

      context "when the submission is on step one" do
        before { submission.status = 'collecting program information' }

        it "returns the step two label" do
          expect(view.step_two_description).to eql(view.step_two_name)
        end
      end

      context "when step two is the current step" do
        before { submission.status = 'collecting committee' }

        context "when degree_type is 'Dissertation'" do
          it "returns a link to complete step two" do
            expect(view.step_two_description).to eq "<a href='#{new_author_submission_committee_members_path(submission)}'>#{view.step_two_name}</a>"
          end
        end

        context "when degree_type is 'Master Thesis'" do
          let(:degree_2) { FactoryBot.create :degree, degree_type: DegreeType.second }

          it "returns a link to complete step two" do
            submission.update degree: degree_2
            expect(view.step_two_description).to eq "<a href='#{new_author_submission_committee_members_path(submission)}'>#{view.step_two_name}</a>"
          end
        end
      end

      context "when step three is the current step" do
        before { submission.status = 'collecting format review files' }

        it "returns a link to edit step two" do
          expect(view.step_two_description).to eq view.step_two_name + "<a href='#{edit_author_submission_committee_members_path(submission)}' class='medium'>[Update My Committee <span class='sr-only'>committee for submission '#{submission.title}' </span>]</a>"
        end
      end

      context "when the submission is beyond step three" do
        it "returns a link to review step two" do
          submission.status = 'waiting for format review response'
          expect(view.step_two_description).to eq view.step_two_name + "<a href='#{author_submission_committee_members_path(submission)}' class='medium'>[Review My Committee <span class='sr-only'>committee for submission '#{submission.title}' </span>]</a>"
        end
      end
    end

    describe '#step_two_status' do
      context 'when the submission has no committee' do
        before { allow(submission.status_behavior).to receive(:beyond_collecting_committee?).and_return(false) }

        it 'returns an empty string' do
          expect(view.step_two_status).to eq ''
        end
      end

      context 'when the submission has a committee' do
        before do
          submission.status = 'collecting format review files'
          submission.committee_provided_at = Time.zone.local(2014, 7, 4)
        end

        it 'returns completed' do
          expect(view.step_two_status).to eq("completed on July 4, 2014")
        end
      end
    end
  end

  describe 'step three: upload format review files' do
    describe '#step_three_class' do
      context "when the submission is before step three" do
        before { allow(submission.status_behavior).to receive(:beyond_collecting_committee?).and_return(false) }

        it "returns an empty string" do
          expect(view.step_three_class).to eq ''
        end
      end

      context "when step three is the current step for the first time" do
        before { submission.status = 'collecting format review files' }

        it "returns 'current'" do
          expect(view.step_three_class).to eq 'current'
        end
      end

      context "when step three has been completed" do
        it "returns 'complete'" do
          submission.status = 'waiting for format review response'
          expect(view.step_three_class).to eq 'complete'
        end
      end
    end

    describe '#step_three_description' do
      context "when the submission is before step three" do
        before { allow(submission.status_behavior).to receive(:beyond_collecting_committee?).and_return(false) }

        it "returns the step three label" do
          expect(view.step_three_description).to eq 'Upload Format Review files'
        end
      end

      context "when step three is the current step for the first time" do
        before do
          submission.status = 'collecting format review files'
          submission.format_review_notes = nil
        end

        it "returns a link to complete step three" do
          expect(view.step_three_description).to eq "<a href='#{author_submission_edit_format_review_path(submission.id)}'>Upload Format Review files</a>"
        end
      end

      context 'when step three is the current step after my format review is rejected' do
        before do
          submission.status = 'collecting format review files'
          submission.format_review_notes = 'some format review notes'
          submission.format_review_rejected_at = Time.zone.now
        end

        it "returns a link to edit step three" do
          expect(view.step_three_description).to eq "Upload Format Review files <a href='/author/submissions/#{submission.id}/format_review/edit' class='medium'>[Update Format Review <span class='sr-only'>format review files for submission '#{submission.title}' </span>]</a>"
        end
      end

      context "when the submission is beyond step three" do
        it "returns a link to review the files" do
          submission.status = 'waiting for format review response'
          expect(view.step_three_description).to eq "Upload Format Review files <a href='/author/submissions/#{submission.id}/format_review' class='medium'>[Review Format Review <span class='sr-only'>format review files for submission '#{submission.title}' </span>]</a>"
        end
      end
    end

    describe '#step_three_status' do
      context "when the submission is before step three" do
        before { allow(submission.status_behavior).to receive(:beyond_collecting_format_review_files?).and_return(false) }

        it 'returns an empty string' do
          expect(view.step_three_status).to eq({})
        end
      end

      context 'when step three has been completed' do
        before do
          submission.status = 'waiting for format review response'
          submission.format_review_files_uploaded_at = Time.zone.local(2014, 7, 4)
        end

        it 'returns completed' do
          expect(view.step_three_status).to eq(partial_name: '/author/shared/completed_indicator', text: "completed on July 4, 2014")
        end
      end

      context 'when step three is the current step after my format review is rejected' do
        before do
          submission.status = 'collecting format review files'
          submission.format_review_notes = 'some format review notes'
          submission.format_review_rejected_at = Time.zone.local(2014, 7, 4)
        end

        it 'returns rejection instructions' do
          expect(view.step_three_status).to eq(partial_name: '/author/shared/rejected_indicator', text: "rejected on July 4, 2014")
        end
      end
    end
  end

  describe 'step four: Graduate school or Honors college approves Format Review files' do
    describe '#step_four_class' do
      context 'when the submission is before waiting for format review response' do
        before { allow(submission.status_behavior).to receive(:beyond_collecting_format_review_files?).and_return(false) }

        it 'returns an empty string' do
          expect(view.step_four_class).to eq ''
        end
      end

      context 'when the submission is currently waiting for format review response' do
        before { submission.status = 'waiting for format review response' }

        it 'returns "current"' do
          expect(view.step_four_class).to eq 'current'
        end
      end

      context "when the submission's Format Review files have been approved" do
        it "returns 'complete'" do
          submission.status = 'collecting final submission files'
          expect(view.step_four_class).to eq 'complete'
        end
      end
    end

    describe '#step_four_status' do
      context 'when the submission is before waiting for format review response' do
        before { submission.status = 'collecting format review files' }

        it 'returns an empty string' do
          expect(view.step_four_status).to eq({})
        end
      end

      context 'when the submission is currently waiting for format review response' do
        before { submission.status = 'waiting for format review response' }

        it 'returns "under review by an administrator"' do
          expect(view.step_four_status).to eq(partial_name: "/author/shared/under_review_indicator")
        end
      end

      context "when the submission's Format Review files have been approved" do
        before do
          submission.status = 'collecting final submission files'
          submission.format_review_approved_at = Time.zone.local(2014, 7, 4)
        end

        it 'returns approved' do
          expect(view.step_four_status).to eq(partial_name: '/author/shared/completed_indicator', text: "review completed on July 4, 2014")
        end
      end
    end
  end

  describe 'step five: Upload Final Submission files' do
    describe '#step_five_class' do
      context "when the submission is before step five" do
        it "returns an empty string" do
          submission.status = 'waiting for format review response'
          expect(view.step_five_class).to eq ''
        end
      end

      context "when step five is the current step" do
        before { submission.status = 'collecting final submission files' }

        it "returns 'current'" do
          expect(view.step_five_class).to eq 'current'
        end
      end

      context "when step five has been completed" do
        it "returns 'complete'" do
          submission.status = 'waiting for final submission response'
          expect(view.step_five_class).to eq 'complete'
        end
      end
    end

    describe '#step_five_description' do
      context "when the submission is before step five" do
        it "returns the step five label" do
          submission.status = 'waiting for format review response'
          expect(view.step_five_description).to eq 'Upload Final Submission Files'
        end
      end

      context "when step five is the current step for the first time" do
        before do
          submission.status = 'collecting final submission files'
          submission.final_submission_rejected_at = nil
        end

        it "returns a link to complete step five" do
          expect(view.step_five_description).to eq "<a href='#{author_submission_edit_final_submission_path(submission)}'>Upload Final Submission Files</a>"
        end
      end

      context "when the submission is beyond step five" do
        it "returns a link to review the files" do
          submission.status = 'waiting for final submission response'
          expect(view.step_five_description).to eq "Upload Final Submission Files <a href='/author/submissions/#{submission.id}/final_submission' class='medium'>[Review Final Submission <span class='sr-only'>final submission files for submission '#{submission.title}'</span>]</a>"
        end
      end
    end

    describe '#step_five_status' do
      context "when the submission is before step five" do
        it 'returns an empty string' do
          submission.status = 'collecting final submission files'
          expect(view.step_five_status).to eq({})
        end
      end

      context 'when step five has been completed' do
        before do
          submission.final_submission_files_uploaded_at = Time.zone.local(2014, 7, 4)
        end

        it 'returns completed' do
          submission.status = 'waiting for final submission response'
          expect(view.step_five_status).to eq(partial_name: '/author/shared/completed_indicator', text: "completed on July 4, 2014")
        end
      end
    end
  end

  describe 'step six: Waiting for committee review' do
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type }

    before do
      submission.degree = degree
    end

    describe '#step_six_class' do
      context "when the submission is before step six" do
        before { allow(submission.status_behavior).to receive(:beyond_collecting_final_submission_files?).and_return(false) }

        it "returns an empty string" do
          expect(view.step_six_class).to eq ''
        end

        it "does not display review page" do
          expect(view.step_six_description).to eq 'Waiting for Committee Review'
        end
      end

      context "when step six is the current step" do
        it "returns 'current' when waiting for committee review" do
          submission.status = 'waiting for committee review'
          expect(view.step_six_class).to eq 'current'
        end

        it "returns 'current' when waiting for head of program review" do
          submission.status = 'waiting for head of program review'
          expect(view.step_six_class).to eq 'current'
        end
      end

      context "when step six has been completed" do
        before { allow(submission.status_behavior).to receive(:beyond_waiting_for_committee_review?).and_return(true) }

        it "returns 'complete'" do
          submission.status = 'waiting for publication release'
          expect(view.step_six_class).to eq 'complete'
        end
      end
    end

    describe '#step_six_status' do
      context 'when the submission is before waiting for committee review' do
        before { submission.status = 'collecting final submission files' }

        it 'returns an empty string' do
          expect(view.step_six_status).to eq({})
        end
      end

      context 'when the submission is currently waiting for committee review' do
        before { submission.status = 'waiting for committee review' }

        it 'returns "under review by committee"' do
          expect(view.step_six_status).to eq(partial_name: '/author/shared/waiting_indicator')
        end
      end

      context 'when the submission is currently waiting for head of program review' do
        before { submission.status = 'waiting for head of program review' }

        it 'returns "under review by head of program"' do
          expect(view.step_six_status).to eq(partial_name: '/author/shared/waiting_indicator')
        end
      end

      context "when the submission's committee approved" do
        before do
          submission.committee_review_accepted_at = Time.zone.local(2014, 7, 4)
          submission.head_of_program_review_accepted_at = Time.zone.local(2014, 7, 5)
        end

        it 'returns approved (w/ head of program)' do
          submission.status = 'waiting for publication release'
          expect(view.step_six_status).to eq(partial_name: '/author/shared/completed_indicator', text: "approved on July 5, 2014")
        end

        it 'returns approved (w/o head of program)' do
          submission.status = 'waiting for publication release'
          submission.degree.degree_type.approval_configuration.head_of_program_is_approving = false
          expect(view.step_six_status).to eq(partial_name: '/author/shared/completed_indicator', text: "approved on July 4, 2014")
        end
      end

      context "when the submission's committee rejected" do
        before do
          submission.committee_review_rejected_at = Time.zone.local(2014, 7, 4)
        end

        it 'returns rejected' do
          submission.status = 'waiting for committee review rejected'
          expect(view.step_six_status).to eq(partial_name: '/author/shared/rejected_indicator', text: "rejected on July 4, 2014")
        end
      end
    end
  end

  describe '#step_six_description' do
    context "when the submission is before step seven" do
      before { allow(submission.status_behavior).to receive(:beyond_collecting_final_submission_files?).and_return(false) }

      it "does not display review page" do
        expect(view.step_six_description).to eq 'Waiting for Committee Review'
      end
    end

    context 'when the submission is currently waiting for committee review' do
      before { submission.status = 'waiting for committee review' }

      it 'to display results page' do
        expect(view.step_six_description).to match(/Waiting for Committee Review.*\[My Committee Review.*\]/)
      end
    end

    context 'when the submission is currently waiting for head of program review' do
      before { submission.status = 'waiting for head of program review' }

      it 'to display results page' do
        expect(view.step_six_description).to match(/Waiting for Committee Review.*\[My Committee Review.*\]/)
      end
    end

    context "when step seven has been completed" do
      before { submission.status = 'waiting for publication release' }

      it 'to display results page' do
        expect(view.step_six_description).to match(/Waiting for Committee Review.*\[My Committee Review.*\]/)
      end
    end

    context "when waiting for committee review rejected" do
      before { submission.status = 'waiting for committee review rejected' }

      it 'to display review and update links' do
        expect(view.step_six_description).to match(/Waiting for Committee Review.*\[My Committee Review.*\[Update.*\]/)
      end
    end
  end

  describe 'step seven: Partner approves Final Submission files' do
    describe '#step_seven_class' do
      context "when the submission is before step seven" do
        before { allow(submission.status_behavior).to receive(:beyond_collecting_final_submission_files?).and_return(false) }

        it "returns an empty string" do
          expect(view.step_seven_class).to eq ''
        end
      end

      context "when step seven is the current step" do
        before { submission.status = 'waiting for final submission response' }

        it "returns 'current'" do
          expect(view.step_seven_class).to eq 'current'
        end
      end

      context "when step seven has been completed" do
        before { allow(submission.status_behavior).to receive(:beyond_waiting_for_final_submission_response_rejected?).and_return(true) }

        it "returns 'complete'" do
          submission.status = 'waiting for publication release'
          expect(view.step_six_class).to eq 'complete'
        end
      end
    end

    describe '#step_seven_status' do
      context 'when the submission is before waiting for final submission response' do
        before { submission.status = 'collecting final submission files' }

        it 'returns an empty string' do
          expect(view.step_seven_status).to eq({})
        end
      end

      context 'when the submission is currently waiting for final submission response' do
        before { submission.status = 'waiting for final submission response' }

        it 'returns "under review by an administrator"' do
          expect(view.step_seven_status).to eq(partial_name: '/author/shared/under_review_indicator')
        end
      end

      context "when the submission's Final Submission files have been approved" do
        before do
          submission.final_submission_approved_at = Time.zone.local(2014, 7, 4)
        end

        it 'returns approved' do
          submission.status = 'waiting for publication release'
          expect(view.step_seven_status).to eq(partial_name: '/author/shared/completed_indicator', text: "approved on July 4, 2014")
        end
      end
    end
  end

  describe 'step eight: Released for Publication' do
    describe '#step_eight_class' do
      context "when the submission is before eight seven" do
        before { allow(submission.status_behavior).to receive(:beyond_waiting_for_head_of_program_review?).and_return(false) }

        it "returns an empty string" do
          expect(view.step_eight_class).to eq ''
        end
      end

      context "when step eight is the current step" do
        before { submission.status = 'waiting for publication release' }

        it "returns 'complete'" do
          expect(view.step_eight_class).to eq 'complete'
        end
      end

      context "when step eight has been completed" do
        before { submission.status = 'released for publication' }

        it "returns 'complete'" do
          expect(view.step_eight_class).to eq 'complete'
        end
      end
    end

    describe '#step_eight_status' do
      context 'when the submission is before step eight' do
        before { allow(submission.status_behavior).to receive(:beyond_waiting_for_head_of_program_review?).and_return(false) }

        it 'returns an empty string' do
          expect(view.step_eight_status).to eq ''
        end
      end

      context 'when the submission is currently waiting for publication release' do
        before do
          submission.status = 'waiting for publication release'
          submission.access_level = 'open_access'
        end

        it 'returns "completed"' do
          expect(view.step_eight_status).to eq "<div class='step complete final'><strong>#{submission.degree_type.name} Submission is Complete</strong></div>"
        end
      end

      context "when the submission has been released for publication" do
        before do
          submission.status = 'released for publication'
        end

        it 'returns completed' do
          expect(view.step_eight_status).to eq "<div class='step complete final'><strong>#{submission.degree_type.name} Submission is Complete</strong></div>"
        end
      end
    end
  end

  describe '#display_format_review_notes?' do
    it 'does not display if notes are empty' do
      submission.format_review_notes = nil
      expect(view.send('display_format_review_notes?', 3)).to be_falsey
    end

    it 'displays notes for step 3' do
      submission.format_review_notes = 'format review note'
      submission.status = 'collecting format review files rejected'
      submission.format_review_rejected_at = Time.zone.yesterday
      expect(view.send('display_format_review_notes?', 3)).to be_truthy
    end

    it 'displays notes for step 4 if format review has not been approved' do
      submission.format_review_approved_at = Time.zone.yesterday
      submission.format_review_notes = 'format review note'
      submission.status = 'collecting final submission files'
      expect(view.send('display_format_review_notes?', 4)).to be_truthy
    end
  end

  describe '#display_final_submission_notes?' do
    it 'does not display if notes are empty' do
      submission.final_submission_notes = nil
      expect(view.send('display_final_submission_notes?', 7)).to be_falsey
    end

    it 'displays notes for step 7' do
      submission.final_submission_notes = 'final rnote'
      submission.status = 'collecting final submission files rejected'
      submission.final_submission_rejected_at = Time.zone.yesterday
      expect(view.send('display_final_submission_notes?', 7)).to be_truthy
    end

    it 'displays notes for step 7 if final submission has been approved' do
      submission.final_submission_approved_at = Time.zone.yesterday
      submission.final_submission_notes = 'final note'
      submission.status = 'waiting for publication release'
      expect(view.send('display_final_submission_notes?', 7)).to be_truthy
    end
  end
end
